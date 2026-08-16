defmodule Spendable.Budgets.Actions.CalculateSpentByMonthTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Budgets
  alias Spendable.Scope
  alias Spendable.Transactions

  setup do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    %{scope: Scope.for_user(user)}
  end

  # The month picker always needs the current month, even before anything is spent in it.
  test "offers the current month with nothing spent", %{scope: scope} do
    current_month = Date.beginning_of_month(Date.utc_today())

    assert [%{month: ^current_month, spent: spent}] = Budgets.calculate_spent_by_month(scope)
    assert Decimal.eq?(spent, 0)
  end

  test "sums what the current month has spent so far", %{scope: scope} do
    current_month = Date.beginning_of_month(Date.utc_today())

    {:ok, _transaction} =
      Transactions.create_transaction(scope, %{
        "amount" => "-25.00",
        "date" => Date.utc_today(),
        "name" => "Groceries"
      })

    assert [%{month: ^current_month, spent: spent}] = Budgets.calculate_spent_by_month(scope)
    assert Decimal.eq?(spent, "-25.00")
  end

  # A transfer moves money between the user's own accounts, so neither side is spending.
  test "leaves a transfer out of the month", %{scope: scope} do
    current_month = Date.beginning_of_month(Date.utc_today())

    {:ok, out} =
      Transactions.create_transaction(scope, %{
        "amount" => "-500.00",
        "date" => Date.utc_today(),
        "name" => "Transfer to savings"
      })

    {:ok, into} =
      Transactions.create_transaction(scope, %{
        "amount" => "500.00",
        "date" => Date.utc_today(),
        "name" => "Transfer from checking"
      })

    {:ok, _pair} = Transactions.mark_as_transfer(scope, out, into)

    assert [%{month: ^current_month, spent: spent}] = Budgets.calculate_spent_by_month(scope)
    assert Decimal.eq?(spent, 0)
  end
end
