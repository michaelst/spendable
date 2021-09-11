defmodule Spendable.Budgets.Budget.Resolver.ListTest do
  use Spendable.Web.ConnCase, async: true

  test "update" do
    user = insert(:user)

    budget = insert(:budget, user_id: user.id)
    insert(:allocation, user_id: user.id, budget: budget, amount: 100)
    insert(:allocation, user_id: user.id, budget: budget, amount: -25.55)
    goal = insert(:goal, user_id: user.id)
    insert(:allocation, user_id: user.id, budget: goal, amount: 54.55)

    query = """
      query {
        budgets {
          id
          name
          balance
          goal
        }
      }
    """

    assert {:ok,
            %{
              data: %{
                "budgets" => [
                  %{
                    "id" => "#{budget.id}",
                    "name" => "Food",
                    "balance" => "#{Decimal.new("74.45")}",
                    "goal" => nil
                  },
                  %{
                    "id" => "#{goal.id}",
                    "name" => "Vacation",
                    "balance" => "#{Decimal.new("54.55")}",
                    "goal" => "#{goal.goal}"
                  }
                ]
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{current_user: user})
  end
end
