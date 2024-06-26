defmodule Spendable.Broadway.SyncMemberTest do
  use Spendable.DataCase, async: true

  import Ash.Query
  import Ecto.Query

  alias Spendable.Api
  alias Spendable.BankAccount
  alias Spendable.BankTransaction
  alias Spendable.Broadway.SyncMember
  alias Spendable.Broadway.SyncMemberTest.TestData
  alias Spendable.Factory
  alias Spendable.Repo
  alias Spendable.Transaction

  setup do
    _pid = start_supervised!({SyncMember, name: __MODULE__})

    TeslaMock
    |> expect(:call, 4, fn
      %{method: :post, url: "https://sandbox.plaid.com/item/get"}, _opts ->
        TeslaHelper.response(body: TestData.item())

      %{
        method: :post,
        url: "https://sandbox.plaid.com/institutions/get_by_id",
        body: body
      },
      _opts ->
        assert %{
                 "client_id" => "test",
                 "institution_id" => "ins_109511",
                 "options" => %{"include_optional_metadata" => true},
                 "secret" => "test"
               } == Jason.decode!(body)

        TeslaHelper.response(body: TestData.institution())

      %{method: :post, url: "https://sandbox.plaid.com/accounts/get"}, _opts ->
        TeslaHelper.response(body: TestData.accounts())

      %{
        method: :post,
        url: "https://sandbox.plaid.com/transactions/get"
      },
      _opts ->
        TeslaHelper.response(body: TestData.account_transactions("zyBMmKBpeZcDVZgqEx3ACKveJjvwmBHomPbyP"))
    end)

    :ok
  end

  test "sync member" do
    user = Factory.user()
    member = Factory.bank_member(user)

    data = %Banks.V1.SyncMemberRequest{member_id: member.id} |> Banks.V1.SyncMemberRequest.encode()

    ref = Broadway.test_message(__MODULE__, data, metadata: %{test_process: self()})
    assert_receive {:ack, ^ref, [_] = _successful, []}, 1000

    bank_accounts =
      from(BankAccount, where: [bank_member_id: ^member.id], order_by: :id) |> Repo.all()

    bank_account =
      Enum.find(bank_accounts, &(&1.external_id == "zyBMmKBpeZcDVZgqEx3ACKveJjvwmBHomPbyP"))

    assert %{
             id: account_id,
             external_id: "zyBMmKBpeZcDVZgqEx3ACKveJjvwmBHomPbyP",
             balance: balance,
             name: "Plaid Gold Standard 0% Interest Checking",
             number: "0000",
             sub_type: "checking",
             sync: true,
             type: "depository"
           } = bank_account

    assert "100" |> Decimal.new() |> Decimal.equal?(balance)

    # there are 8 transactions in test data but one is a pending that gets replaced
    assert 7 == from(BankTransaction, where: [user_id: ^user.id]) |> Repo.aggregate(:count, :id)

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
             name: name,
             date: ~D[2022-06-10],
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
                   name: budget_name
                 }
               }
             ]
           } = transaction

    assert to_string(budget_name) == "Spendable"
    assert to_string(name) == "Uber 072515 SF**POOL**"
    assert Decimal.equal?("-6.33", amount)
    assert Decimal.equal?("-6.33", allocation_amount)
  end
end
