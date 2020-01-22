defmodule Spendable.Budgets.BudgetTemplate.Resolver.ListTest do
  use Spendable.Web.ConnCase, async: true
  import Spendable.Factory

  test "update", %{conn: conn} do
    {user, token} = Spendable.TestUtils.create_user()

    template1 = insert(:budget_template, user_id: user.id)
    template2 = insert(:budget_template, user_id: user.id)

    query = """
      query {
        budgetTemplates {
          name
          lines {
            amount
            budget {
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
                   "lines" => [
                     %{
                       "amount" => "#{template1.lines |> List.first() |> Map.get(:amount)}",
                       "budget" => %{"name" => "Food"}
                     },
                     %{
                       "amount" => "#{template1.lines |> List.last() |> Map.get(:amount)}",
                       "budget" => %{"name" => "Food"}
                     }
                   ],
                   "name" => "Payday"
                 },
                 %{
                   "lines" => [
                     %{
                       "amount" => "#{template2.lines |> List.first() |> Map.get(:amount)}",
                       "budget" => %{"name" => "Food"}
                     },
                     %{
                       "amount" => "#{template2.lines |> List.last() |> Map.get(:amount)}",
                       "budget" => %{"name" => "Food"}
                     }
                   ],
                   "name" => "Payday"
                 }
               ]
             }
           } == response
  end
end
