defmodule Spendable.User.Calculations.SpendableTest do
  use Spendable.DataCase, async: true
  import Spendable.Factory

  alias Spendable.TestUtils
  alias Spendable.User.Calculations.Spendable

  test "calculate spendable" do
    user = TestUtils.create_user()

    insert(:bank_account, user: user, balance: 100)
    budget = insert(:budget, user: user)
    insert(:allocation, user: user, budget: budget, amount: -25.55)
    budget = insert(:budget, user: user, adjustment: "0.01")
    insert(:allocation, user: user, budget: budget, amount: 10)

    expected_spendable = Decimal.new("64.44")
    {:ok, [calculation]} = Spendable.calculate([user], [], %{})

    assert Decimal.eq?(expected_spendable, calculation)
  end

  test "calculate spendable for new user" do
    user = TestUtils.create_user()

    expected_spendable = Decimal.new("0.00")
    {:ok, [calculation]} = Spendable.calculate([user], [], %{})

    assert Decimal.eq?(expected_spendable, calculation)
  end
end
