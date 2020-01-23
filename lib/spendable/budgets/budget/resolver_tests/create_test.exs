defmodule Spendable.Budgets.Budget.Resolver.CreateTest do
  use Spendable.Web.ConnCase, async: true

  test "create budget", %{conn: conn} do
    {_user, token} = Spendable.TestUtils.create_user()

    query = """
      mutation {
        createBudget(
          name: "test budget",
          balance: "10.51"
        ) {
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
               "createBudget" => %{
                 "name" => "test budget",
                 "balance" => "10.51",
                 "goal" => nil
               }
             }
           } == response
  end

  test "create goal", %{conn: conn} do
    {_user, token} = Spendable.TestUtils.create_user()

    query = """
      mutation {
        createBudget(
          name: "test budget",
          balance: "10.51",
          goal: "1000.25"
        ) {
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
               "createBudget" => %{
                 "name" => "test budget",
                 "balance" => "10.51",
                 "goal" => "1000.25"
               }
             }
           } == response
  end
end
