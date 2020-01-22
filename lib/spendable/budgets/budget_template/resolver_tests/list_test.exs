defmodule Spendable.Budgets.BudgetTemplate.Resolver.ListTest do
  use Spendable.Web.ConnCase, async: true

  alias Spendable.Budgets.Budget
  alias Spendable.Budgets.BudgetTemplate
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

    template1 =
      %BudgetTemplate{}
      |> BudgetTemplate.changeset(%{
        user_id: user.id,
        name: "template",
        lines: [
          %{
            amount: 5,
            budget_id: budget.id,
            priority: 0
          },
          %{
            amount: 7,
            budget_id: budget.id,
            priority: 2
          }
        ]
      })
      |> Repo.insert!()

    template2 =
      %BudgetTemplate{}
      |> BudgetTemplate.changeset(%{
        user_id: user.id,
        name: "template",
        lines: [
          %{
            amount: 8,
            budget_id: budget.id,
            priority: 0
          }
        ]
      })
      |> Repo.insert!()

    query = """
      query {
        budgetTemplates {
          id
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
               "budgetTemplates" => [
                 %{
                   "id" => "#{template1.id}",
                   "lines" => [
                     %{"amount" => "5.00", "budget" => %{"id" => "#{budget.id}", "name" => "test budget"}, "priority" => 0},
                     %{"amount" => "7.00", "budget" => %{"id" => "#{budget.id}", "name" => "test budget"}, "priority" => 2}
                   ],
                   "name" => "template"
                 },
                 %{
                   "id" => "#{template2.id}",
                   "lines" => [
                     %{"amount" => "8.00", "budget" => %{"id" => "#{budget.id}", "name" => "test budget"}, "priority" => 0}
                   ],
                   "name" => "template"
                 }
               ]
             }
           } == response
  end
end
