defmodule Spendable.Budgets.AllocationTemplate.Resolver.UpdateTest do
  use Spendable.Web.ConnCase, async: true
  import Spendable.Factory

  test "update budget template", %{conn: conn} do
    {user, token} = Spendable.TestUtils.create_user()

    budget = insert(:budget, user: user)

    %{lines: [line | _]} = template = insert(:allocation_template, user: user)

    query = """
      mutation {
        updateAllocationTemplate(
          id: #{template.id},
          name: "new name"
          lines: [
            {
              id: "#{line.id}"
              amount: "10"
              budget_id: "#{budget.id}"
              priority: 0
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
               "updateAllocationTemplate" => %{
                 "id" => "#{template.id}",
                 "name" => "new name",
                 "lines" => [
                   %{
                     "amount" => "10.00",
                     "budget" => %{"id" => "#{budget.id}", "name" => "Food"},
                     "priority" => 0
                   },
                   %{
                     "amount" => "12.00",
                     "budget" => %{"id" => "#{budget.id}", "name" => "Food"},
                     "priority" => 1
                   }
                 ]
               }
             }
           } == response
  end
end
