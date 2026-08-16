defmodule Spendable.Banks.Actions.UpdateBankTransactionTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Banks
  alias Spendable.Banks.Schemas.BankTransaction
  alias Spendable.Budgets
  alias Spendable.Scope
  alias Spendable.TestData
  alias Spendable.Transactions

  setup do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    scope = Scope.for_user(user)
    {_account, bank_transaction} = TestData.FinanceKit.card_with_charge(scope)

    %{scope: scope, bank_transaction: bank_transaction}
  end

  test "restates the charge and the transaction it produced", %{
    scope: scope,
    bank_transaction: bank_transaction
  } do
    attrs = %{amount: Decimal.new("-22.50"), date: ~D[2026-08-02], name: "Coffee Roasters", pending: false}

    assert {:ok, %BankTransaction{pending: false}} =
             Banks.update_bank_transaction(scope, bank_transaction, attrs)

    assert [%{name: "Coffee Roasters", date: ~D[2026-08-02], amount: amount}] =
             Transactions.list_transactions(scope)

    assert Decimal.eq?(amount, "-22.50")
  end

  # The whole reason to update in place: the user already decided where this money came from, and
  # a charge settling for a different amount must not ask them again.
  test "keeps what the user allocated and moves only the remainder", %{
    scope: scope,
    bank_transaction: bank_transaction
  } do
    {:ok, budget} = Budgets.create_budget(scope, %{"name" => "Coffee"})
    [transaction] = Transactions.list_transactions(scope)

    {:ok, _allocated} =
      Transactions.update_transaction(scope, transaction, %{
        "budget_allocations" => %{"0" => %{"amount" => "-5.00", "budget_id" => budget.id}}
      })

    attrs = %{amount: Decimal.new("-22.50"), date: ~D[2026-08-01], name: "Coffee", pending: false}
    {:ok, _updated} = Banks.update_bank_transaction(scope, bank_transaction, attrs)

    {:ok, spendable} = Budgets.find_or_create_spendable_budget(scope)
    [restated] = Transactions.list_transactions(scope)
    by_budget = Map.new(restated.budget_allocations, &{&1.budget_id, &1.amount})

    assert Decimal.eq?(by_budget[budget.id], "-5.00")
    assert Decimal.eq?(by_budget[spendable.id], "-17.50")
  end

  test "refuses a charge belonging to another user", %{bank_transaction: bank_transaction} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    attrs = %{amount: Decimal.new("-1.00"), date: ~D[2026-08-01], name: "Theirs", pending: false}

    assert {:error, :not_authorized} =
             Banks.update_bank_transaction(Scope.for_user(other_user), bank_transaction, attrs)
  end
end
