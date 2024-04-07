defmodule Spendable.User.Calculations.SpendableTest do
  use Spendable.DataCase, async: true

  alias Spendable.Factory
  alias Spendable.User.Calculations.Spendable, as: Calculation

  test "calculate spendable" do
    user = Factory.user()

    bank_member = Factory.bank_member(user)

    Factory.bank_account(bank_member, balance: 100)

    transaction = Factory.transaction(user)

    budget = Factory.budget(user)

    Factory.budget_allocation(budget, transaction, amount: -25.55)

    budget = Factory.budget(user, adjustment: Decimal.new("0.01"))

    Factory.budget_allocation(budget, transaction, amount: 10)

    # budget that only tracks spending should be ignored
    budget = Factory.budget(user, type: :tracking)

    Factory.budget_allocation(budget, transaction, amount: 10)

    expected_spendable = Decimal.new("64.44")
    {:ok, [calculation]} = Calculation.calculate([user], [], %{})

    assert Decimal.eq?(expected_spendable, calculation)
  end

  test "calculate spendable for new user" do
    user = Factory.user()

    expected_spendable = Decimal.new("0.00")
    {:ok, [calculation]} = Calculation.calculate([user], [], %{})

    assert Decimal.eq?(expected_spendable, calculation)
  end
end
