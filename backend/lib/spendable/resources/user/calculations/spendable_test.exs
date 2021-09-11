defmodule Spendable.User.Calculations.SpendableTest do
  use Spendable.DataCase, async: true

  alias Spendable.User.Calculations.Spendable

  test "calculate spendable" do
    user = insert(:user)

    bank_member = insert(:bank_member, user_id: user.id)
    insert(:bank_account, user_id: user.id, bank_member_id: bank_member.id, balance: 100)
    budget = insert(:budget, user_id: user.id)
    insert(:allocation, user_id: user.id, budget: budget, amount: -25.55)
    budget = insert(:budget, user_id: user.id, adjustment: "0.01")
    insert(:allocation, user_id: user.id, budget: budget, amount: 10)

    expected_spendable = Decimal.new("64.44")
    {:ok, [calculation]} = Spendable.calculate([user], [], %{})

    assert Decimal.eq?(expected_spendable, calculation)
  end

  test "calculate spendable for new user" do
    user = insert(:user)

    expected_spendable = Decimal.new("0.00")
    {:ok, [calculation]} = Spendable.calculate([user], [], %{})

    assert Decimal.eq?(expected_spendable, calculation)
  end
end
