defmodule Spendable.User.Calculations.SpendableTest do
  use Spendable.DataCase, async: true

  alias Spendable.User.Calculations.Spendable, as: Calculation

  test "calculate spendable" do
    user = Factory.insert(Spendable.User)

    bank_member = Factory.insert(Spendable.BankMember, user_id: user.id)

    Factory.insert(Spendable.BankAccount,
      user_id: user.id,
      bank_member_id: bank_member.id,
      balance: 100
    )

    transaction = Factory.insert(Spendable.Transaction, user_id: user.id)

    budget = Factory.insert(Spendable.Budget, user_id: user.id)

    Factory.insert(Spendable.BudgetAllocation,
      user_id: user.id,
      budget_id: budget.id,
      transaction_id: transaction.id,
      amount: -25.55
    )

    budget = Factory.insert(Spendable.Budget, user_id: user.id, adjustment: Decimal.new("0.01"))

    Factory.insert(Spendable.BudgetAllocation,
      user_id: user.id,
      budget_id: budget.id,
      transaction_id: transaction.id,
      amount: 10
    )

    # budget that only tracks spending should be ignored
    budget = Factory.insert(Spendable.Budget, user_id: user.id, track_spending_only: true)

    Factory.insert(Spendable.BudgetAllocation,
      user_id: user.id,
      budget_id: budget.id,
      transaction_id: transaction.id,
      amount: 10
    )

    expected_spendable = Decimal.new("64.44")
    {:ok, [calculation]} = Calculation.calculate([user], [], %{})

    assert Decimal.eq?(expected_spendable, calculation)
  end

  test "calculate spendable for new user" do
    user = Factory.insert(Spendable.User)

    expected_spendable = Decimal.new("0.00")
    {:ok, [calculation]} = Calculation.calculate([user], [], %{})

    assert Decimal.eq?(expected_spendable, calculation)
  end
end
