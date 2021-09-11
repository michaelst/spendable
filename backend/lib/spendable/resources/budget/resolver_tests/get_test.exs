defmodule Spendable.Budgets.Budget.Resolver.GetTest do
  use Spendable.Web.ConnCase, async: true

  test "update" do
    user = insert(:user)

    budget = insert(:budget, user_id: user.id)
    insert(:allocation, user_id: user.id, budget: budget, amount: 100)
    insert(:allocation, user_id: user.id, budget: budget, amount: -25.55)

    query = """
    query {
      budget(id: "#{budget.id}") {
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
                "budget" => %{
                  "id" => "#{budget.id}",
                  "name" => "Food",
                  "balance" => "#{Decimal.new("74.45")}",
                  "goal" => nil
                }
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{current_user: user})
  end
end
