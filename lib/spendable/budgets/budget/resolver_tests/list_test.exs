defmodule Spendable.Budgets.Budget.Resolver.ListTest do
  use Spendable.Web.ConnCase, async: true

  alias Spendable.Budgets.Budget
  alias Spendable.Repo

  test "update", %{conn: conn} do
    {user, token} = Spendable.TestUtils.create_user()

    budget =
      %Budget{}
      |> Budget.changeset(%{
        user_id: user.id,
        name: "test budget",
        balance: 10.50
      })
      |> Repo.insert!()

    goal =
      %Budget{}
      |> Budget.changeset(%{
        user_id: user.id,
        name: "test goal",
        balance: 10.25,
        goal: 10.25
      })
      |> Repo.insert!()

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
                   "name" => "test budget",
                   "balance" => "10.50",
                   "goal" => nil
                 },
                 %{
                   "id" => "#{goal.id}",
                   "name" => "test goal",
                   "balance" => "10.25",
                   "goal" => "10.25"
                 }
               ]
             }
           } == response
  end
end
