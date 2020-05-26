defmodule Spendable.Budgets.AllocationTemplate.Resolver.ListTest do
  use Spendable.Web.ConnCase, async: true
  import Spendable.Factory

  test "update", %{conn: conn} do
    {user, token} = Spendable.TestUtils.create_user()

    template1 = insert(:allocation_template, user: user)
    template2 = insert(:allocation_template, user: user)

    query = """
      query {
        allocationTemplates {
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
               "allocationTemplates" => [
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
                 },
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
                 }
               ]
             }
           } == response
  end
end
