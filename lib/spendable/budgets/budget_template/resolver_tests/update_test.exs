defmodule Spendable.Budgets.BudgetTemplate.Resolver.UpdateTest do
  use Spendable.Web.ConnCase, async: true

  alias Spendable.Budgets.Budget
  alias Spendable.Budgets.BudgetTemplate
  alias Spendable.Repo

  test "update budget template", %{conn: conn} do
    {user, token} = Spendable.TestUtils.create_user()

    budget =
      %Budget{}
      |> Budget.changeset(%{
        user_id: user.id,
        name: "test",
        balance: 10
      })
      |> Repo.insert!()

    %{lines: [line | _]} =
      template =
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

    query = """
      mutation {
        updateBudgetTemplate(
          id: #{template.id},
          name: "new name"
          lines: [
            {
              id: "#{line.id}"
              amount: "10"
            }
            {
              amount: "12"
              priority: 1
              budget_id: "#{budget.id}"
            }
          ]
        ) {
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
               "updateBudgetTemplate" => %{
                 "id" => "#{template.id}",
                 "name" => "new name",
                 "lines" => [
                   %{
                     "amount" => "10.00",
                     "budget" => %{"id" => "#{budget.id}", "name" => "test"},
                     "priority" => 0
                   },
                   %{
                     "amount" => "12.00",
                     "budget" => %{"id" => "#{budget.id}", "name" => "test"},
                     "priority" => 1
                   }
                 ]
               }
             }
           } == response
  end
end
