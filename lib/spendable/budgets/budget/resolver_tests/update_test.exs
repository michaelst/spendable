defmodule Spendable.Budgets.Budget.Resolver.UpdateTest do
  use Spendable.Web.ConnCase, async: true
  import Spendable.Factory

  alias Spendable.Repo

  test "update budget", %{conn: conn} do
    {user, token} = Spendable.TestUtils.create_user()

    budget = insert(:budget, user: user)
    insert(:allocation, user: user, budget: budget, amount: 10)

    query = """
      mutation {
        updateBudget(id: #{budget.id}, name: "new name") {
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
                 "balance" => "10.00",
                 "goal" => nil
               }
             }
           } == response

    query = """
      mutation {
        updateBudget(id: #{budget.id}, name: "new name", balance: "10.05") {
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
                 "balance" => "10.05",
                 "goal" => nil
               }
             }
           } == response

    assert Repo.get(Spendable.Budgets.Budget, budget.id).adjustment |> Decimal.eq?("0.05")
  end
end
