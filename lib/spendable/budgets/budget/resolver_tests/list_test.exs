defmodule Spendable.Budgets.Budget.Resolver.ListTest do
  use Spendable.Web.ConnCase, async: true
  import Spendable.Factory

  test "update", %{conn: conn} do
    {user, token} = Spendable.TestUtils.create_user()

    budget = insert(:budget, user: user)
    insert(:allocation, user: user, budget: budget, amount: 100)
    insert(:allocation, user: user, budget: budget, amount: -25.55)
    goal = insert(:goal, user: user)
    insert(:allocation, user: user, budget: goal, amount: 54.55)

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

    response =
      conn
      |> put_req_header("authorization", "Bearer #{token}")
      |> post("/graphql", %{query: query})
      |> json_response(200)

    assert %{
             "data" => %{
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
           } == response
  end
end
