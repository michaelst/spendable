defmodule Spendable.Banks.Actions.IngestBankTransactionsTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Banks
  alias Spendable.Scope
  alias Spendable.TestData
  alias Spendable.Transactions

  setup do
    stub(TeslaMock, :call, fn
      %{method: :post, url: "https://sandbox.plaid.com/item/public_token/exchange"}, _opts ->
        TeslaHelper.response(body: %{"access_token" => "access-sandbox-token"})

      %{method: :post, url: "https://sandbox.plaid.com/item/get"}, _opts ->
        TeslaHelper.response(body: TestData.Plaid.item())

      %{method: :post, url: "https://sandbox.plaid.com/institutions/get_by_id"}, _opts ->
        TeslaHelper.response(body: TestData.Plaid.institution())
    end)

    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{
        external_id: Ecto.UUID.generate(),
        provider: "google",
        bank_limit: 1
      })

    scope = Scope.for_user(user)
    {:ok, bank_member} = Banks.create_bank_member_from_public_token(scope, "public-sandbox-token")

    {:ok, bank_account} =
      Banks.upsert_bank_account(scope, bank_member, %{
        balance: Decimal.new("100.00"),
        external_id: "acct-1",
        name: "Checking",
        sub_type: "checking",
        type: "depository"
      })

    entry = %{
      amount: Decimal.new("-12.50"),
      date: ~D[2026-08-01],
      external_id: "txn-1",
      name: "Coffee",
      pending: false,
      replaces: nil
    }

    %{scope: scope, bank_account: bank_account, entry: entry}
  end

  test "gives the user a transaction for each new entry", %{
    scope: scope,
    bank_account: bank_account,
    entry: entry
  } do
    entries = [entry, %{entry | external_id: "txn-2", name: "Lunch"}]

    assert {:ok, 2} = Banks.ingest_bank_transactions(scope, bank_account, entries)
    assert [%{name: "Lunch"}, %{name: "Coffee"}] = Transactions.list_transactions(scope)
  end

  # Every source replays activity we already hold, so a repeat is the normal case rather than a
  # failure, and it must not hand the user the same charge twice.
  test "counts a replayed entry as nothing new", %{
    scope: scope,
    bank_account: bank_account,
    entry: entry
  } do
    {:ok, 1} = Banks.ingest_bank_transactions(scope, bank_account, [entry])

    assert {:ok, 0} = Banks.ingest_bank_transactions(scope, bank_account, [entry])
    assert [%{name: "Coffee"}] = Transactions.list_transactions(scope)
  end

  test "a settled entry replaces the pending entry it names", %{
    scope: scope,
    bank_account: bank_account,
    entry: entry
  } do
    {:ok, 1} = Banks.ingest_bank_transactions(scope, bank_account, [%{entry | pending: true}])

    settled = %{entry | external_id: "txn-2", name: "Coffee Roasters", replaces: "txn-1"}

    assert {:ok, 1} = Banks.ingest_bank_transactions(scope, bank_account, [settled])
    assert [%{name: "Coffee Roasters"}] = Transactions.list_transactions(scope)
  end

  test "refuses an account belonging to another user", %{bank_account: bank_account, entry: entry} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    assert {:error, :not_authorized} =
             Banks.ingest_bank_transactions(Scope.for_user(other_user), bank_account, [entry])
  end
end
