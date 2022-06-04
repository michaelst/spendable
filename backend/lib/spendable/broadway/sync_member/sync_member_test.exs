defmodule Spendable.Broadway.SyncMemberTest do
  use Spendable.DataCase, async: false

  import Ash.Query
  import Ecto.Query
  import Mock
  import Tesla.Mock

  alias Google.PubSub
  alias Spendable.Api
  alias Spendable.BankAccount
  alias Spendable.BankTransaction
  alias Spendable.Broadway.SyncMember
  alias Spendable.Broadway.SyncMemberTest.TestData
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
    user = Factory.insert(Spendable.User)
    member = Factory.insert(Spendable.BankMember, user_id: user.id)

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

    # there are 8 transactions in test data but one is a pending that gets replaced
    assert 7 == from(BankTransaction, where: [user_id: ^user.id]) |> Repo.aggregate(:count, :id)

    today = Date.utc_today()

    [
      %{},
      %{},
      %{},
      %{},
      %{},
      %{},
      transaction
    ] =
      Transaction
      |> filter(user_id: user.id)
      |> sort([:date])
      |> load([:bank_transaction, budget_allocations: :budget])
      |> Api.read!()

    assert %{
             amount: amount,
             name: "Uber 072515 SF**POOL**",
             date: ^today,
             bank_transaction: %{
               external_id: "gjwAb9wKgytqA9dKR4Xmc3rwN8WN5nigoEkrB",
               bank_account_id: ^account_id,
               name: "Uber 072515 SF**POOL**",
               pending: false
             },
             budget_allocations: [
               %{
                 amount: allocation_amount,
                 budget: %{
                   name: "Spendable"
                 }
               }
             ]
           } = transaction

    assert Decimal.equal?("-6.33", amount)
    assert Decimal.equal?("-6.33", allocation_amount)

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
