defmodule Spendable.Budgets.Budget.Resolver.UpdateTest do
  use Spendable.Web.ConnCase, async: true
  import Spendable.Factory

  test "update budget", %{conn: conn} do
    {user, token} = Spendable.TestUtils.create_user()

    budget = insert(:budget, user_id: user.id)

    query = """
      mutation {
        updateBudget(id: #{budget.id}, name: "new name", balance: "10.25") {
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
               "updateBudget" => %{
                 "id" => "#{budget.id}",
                 "name" => "new name",
                 "balance" => "10.25",
                 "goal" => nil
               }
             }
           } == response
  end
end