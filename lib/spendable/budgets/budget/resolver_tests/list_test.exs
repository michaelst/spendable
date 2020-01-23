defmodule Spendable.Budgets.Budget.Resolver.ListTest do
  use Spendable.Web.ConnCase, async: true
  import Spendable.Factory

  test "update", %{conn: conn} do
    {user, token} = Spendable.TestUtils.create_user()

    budget = insert(:budget, user_id: user.id)
    goal = insert(:goal, user_id: user.id)

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
                   "id" => "#{goal.id}",
                   "name" => "Vacation",
                   "balance" => "#{goal.balance}",
                   "goal" => "#{goal.goal}"
                 },
                 %{
                   "id" => "#{budget.id}",
                   "name" => "Food",
                   "balance" => "#{budget.balance}",
                   "goal" => nil
                 }
               ]
             }
           } == response
  end
end
