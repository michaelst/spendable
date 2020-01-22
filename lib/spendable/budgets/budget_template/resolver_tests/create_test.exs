defmodule Spendable.Budgets.BudgetTemplate.Resolver.CreateTest do
  use Spendable.Web.ConnCase, async: true

  alias Spendable.Budgets.Budget
  alias Spendable.Repo

  test "create budget template", %{conn: conn} do
    {user, token} = Spendable.TestUtils.create_user()

    budget =
      %Budget{}
      |> Budget.changeset(%{
        user_id: user.id,
        name: "test budget",
        balance: 10.50
      })
      |> Repo.insert!()

    query = """
      mutation {
        createBudgetTemplate(
          name: "test budget template"
          lines: [
            {
              amount: "5"
              budget_id: "#{budget.id}"
              priority: 0
            }
          ]
        ) {
          name
          lines {
            amount
            priority
            budget {
              id
              name
            }
          }
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
               "createBudgetTemplate" => %{
                 "name" => "test budget template",
                 "lines" => [
                   %{
                     "amount" => "5.00",
                     "budget" => %{"id" => "#{budget.id}", "name" => "test budget"},
                     "priority" => 0
                   }
                 ]
               }
             }
           } == response
  end
end
