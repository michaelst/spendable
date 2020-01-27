defmodule Spendable.Budgets.Budget.Resolver.DeleteTest do
  use Spendable.Web.ConnCase, async: true
  import Spendable.Factory

  test "delete budget", %{conn: conn} do
    {user, token} = Spendable.TestUtils.create_user()

    budget = insert(:budget, user_id: user.id)

    query = """
      mutation {
        deleteBudget(id: #{budget.id}) {
          id
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
               "deleteBudget" => %{
                 "id" => "#{budget.id}"
               }
             }
           } == response
  end
end
