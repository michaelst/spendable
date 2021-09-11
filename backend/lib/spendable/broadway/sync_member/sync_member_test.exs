defmodule Spendable.Broadway.SyncMemberTest do
  use Spendable.DataCase, async: false

  import Ash.Query
  import Ecto.Query
  import Mock
  import Tesla.Mock

  alias Google.PubSub
  alias Spendable.Api
  alias Spendable.BankAccount
  alias Spendable.BankMember
  alias Spendable.BankTransaction
  alias Spendable.Broadway.SyncMember
  alias Spendable.Broadway.SyncMemberTest.TestData
  alias Spendable.Plaid.Adapter
  alias Spendable.Repo
  alias Spendable.TestUtils
  alias Spendable.Transaction

  setup do
    mock_global(fn
      %{method: :post, url: "https://sandbox.plaid.com/item/get"} ->
        json(TestData.item())

      %{
        method: :post,
        url: "https://sandbox.plaid.com/institutions/get_by_id",
        body:
          "{\"client_id\":\"test\",\"institution_id\":\"ins_109511\",\"options\":{\"include_optional_metadata\":true},\"secret\":\"test\"}"
      } ->
        json(TestData.institution())

      %{method: :post, url: "https://sandbox.plaid.com/accounts/get"} ->
        json(TestData.accounts())

      %{
        method: :post,
        url: "https://sandbox.plaid.com/transactions/get"
      } ->
        json(TestData.account_transactions("zyBMmKBpeZcDVZgqEx3ACKveJjvwmBHomPbyP"))
    end)

    :ok
  end

  test "sync member" do
    user = insert(:user)
    token = "access-sandbox-97a66034-85df-4510-8eb5-020cc7997134"
    {:ok, %{body: details}} = Plaid.item(token)

    formatted_data = details |> Adapter.bank_member() |> Map.put(:plaid_token, token)

    member =
      BankMember
      |> Ash.Changeset.for_create(:create, formatted_data)
      |> Ash.Changeset.replace_relationship(:user, user)
      |> Ash.Changeset.force_change_attributes(formatted_data)
      |> Api.create!()

    data = %SyncMemberRequest{member_id: member.id} |> SyncMemberRequest.encode()

    ref = Broadway.test_message(SyncMember, data)
    assert_receive {:ack, ^ref, [_] = _successful, []}, 1000

    bank_accounts = from(BankAccount, where: [bank_member_id: ^member.id], order_by: :id) |> Repo.all()

    assert [
             %{sync: false},
             %{sync: false},
             %{sync: false},
             %{sync: false},
             %{sync: false},
             %{sync: false},
             %{sync: false},
             %{sync: false}
           ] = bank_accounts

    bank_account = Enum.find(bank_accounts, &(&1.external_id == "zyBMmKBpeZcDVZgqEx3ACKveJjvwmBHomPbyP"))

    assert %{
             id: account_id,
             external_id: "zyBMmKBpeZcDVZgqEx3ACKveJjvwmBHomPbyP",
             balance: balance,
             name: "Plaid Gold Standard 0% Interest Checking",
             number: "0000",
             sub_type: "checking",
             sync: false,
             type: "depository"
           } = bank_account

    assert "100" |> Decimal.new() |> Decimal.equal?(balance)

    assert 0 == from(BankTransaction, where: [user_id: ^user.id]) |> Repo.aggregate(:count, :id)

    test_pid = self()

    with_mock(
      PubSub,
      [],
      publish: fn data, _topic ->
        send(test_pid, data)
        {:ok, %{status: 200}}
      end
    ) do
      bank_account
      |> Ash.Changeset.for_update(:update, %{sync: true})
      |> Api.update!()

      ref = Broadway.test_message(SyncMember, data)
      assert_receive {:ack, ^ref, [_] = _successful, []}, 1000
    end

    assert 7 == from(BankTransaction, where: [user_id: ^user.id]) |> Repo.aggregate(:count, :id)

    today = Date.utc_today()

    assert [
             %{},
             %{},
             %{},
             %{},
             %{},
             %{},
             %{
               amount: amount,
               name: "Uber 072515 SF**POOL**",
               date: ^today,
               bank_transaction: %{
                 external_id: "gjwAb9wKgytqA9dKR4Xmc3rwN8WN5nigoEkrB",
                 bank_account_id: ^account_id,
                 name: "Uber 072515 SF**POOL**",
                 pending: false
               }
             }
           ] =
             Transaction
             |> filter(user_id: user.id)
             |> sort([:date])
             |> load(:bank_transaction)
             |> Api.read!()

    assert "-6.33" |> Decimal.new() |> Decimal.equal?(amount)

    TestUtils.assert_published([
      %SendNotificationRequest{
        body: "$6.33",
        title: "Uber 072515 SF**POOL**",
        user_id: user.id
      },
      %SendNotificationRequest{
        body: "$5.40",
        title: "Uber 063015 SF**POOL**",
        user_id: user.id
      },
      %SendNotificationRequest{body: "$500.00", title: "United Airlines", user_id: user.id},
      %SendNotificationRequest{body: "$12.00", title: "McDonald's", user_id: user.id},
      %SendNotificationRequest{body: "$4.33", title: "Starbucks", user_id: user.id},
      %SendNotificationRequest{body: "$89.40", title: "SparkFun", user_id: user.id},
      %SendNotificationRequest{
        body: "$6.33",
        title: "Uber 072515 SF**POOL**",
        user_id: user.id
      }
    ])
  end
end
