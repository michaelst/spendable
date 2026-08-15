defmodule Spendable.Banks.Actions.SyncMemberTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Banks
  alias Spendable.Banks.Schemas.BankMember
  alias Spendable.Scope
  alias Spendable.TestData
  alias Spendable.Transactions

  setup do
    stub(TeslaMock, :call, fn
      %{method: :post, url: "https://sandbox.plaid.com/item/get"}, _opts ->
        TeslaHelper.response(body: TestData.Plaid.item())

      %{method: :post, url: "https://sandbox.plaid.com/institutions/get_by_id"}, _opts ->
        TeslaHelper.response(body: TestData.Plaid.institution())

      %{method: :post, url: "https://sandbox.plaid.com/accounts/get"}, _opts ->
        TeslaHelper.response(body: TestData.Plaid.accounts())

      %{method: :post, url: "https://sandbox.plaid.com/transactions/get"}, _opts ->
        TeslaHelper.response(body: TestData.Plaid.account_transactions("zyBMmKBpeZcDVZgqEx3ACKveJjvwmBHomPbyP"))
    end)

    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    {:ok, bank_member} =
      Repo.insert(%BankMember{
        user_id: user.id,
        external_id: "jQ3ZbE3BWqUMeqNBgDK6fjdyErroNwu1EPKnL",
        name: "Plaid",
        provider: "Plaid",
        plaid_token: "access-sandbox-token"
      })

    %{scope: Scope.for_user(user), bank_member: bank_member}
  end

  test "names the connection from the institution", %{scope: scope, bank_member: bank_member} do
    :ok = Banks.sync_member(bank_member.id)

    assert [%{name: "Tartan Bank", status: "CONNECTED", institution_id: "ins_109511"}] =
             Banks.list_bank_members(scope)
  end

  test "brings the accounts across", %{scope: scope, bank_member: bank_member} do
    :ok = Banks.sync_member(bank_member.id)

    assert [%{bank_accounts: accounts}] = Banks.list_bank_members(scope)
    assert Enum.any?(accounts, &(&1.external_id == "zyBMmKBpeZcDVZgqEx3ACKveJjvwmBHomPbyP"))
  end

  # Every synced transaction becomes one the user can allocate, and until they do it waits in
  # Spendable.
  test "creates a transaction for each synced charge", %{scope: scope, bank_member: bank_member} do
    :ok = Banks.sync_member(bank_member.id)

    transactions = Transactions.list_transactions(scope, per_page: 100)

    refute Enum.empty?(transactions)
    assert Enum.all?(transactions, &(is_binary(&1.bank_transaction_id) and &1.reviewed == false))
  end

  test "errors when no member has that id" do
    assert {:error, :bank_member_not_found} =
             Banks.sync_member("bkm_01M036GTQ48JXS0A2AXFNV6H5P")
  end
end
