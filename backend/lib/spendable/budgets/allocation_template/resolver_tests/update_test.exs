defmodule Spendable.Budgets.AllocationTemplate.Resolver.UpdateTest do
  use Spendable.Web.ConnCase, async: true
  import Spendable.Factory

  test "update budget template" do
    user = Spendable.TestUtils.create_user()

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
            }
            {
              amount: "12"
              budget_id: "#{budget.id}"
            }
          ]
        ) {
          id
          name
          lines {
            amount
            budget {
              id
              name
            }
          }
        }
      }
    """

    assert {:ok,
            %{
              data: %{
                "updateAllocationTemplate" => %{
                  "id" => "#{template.id}",
                  "name" => "new name",
                  "lines" => [
                    %{
                      "amount" => "10.00",
                      "budget" => %{"id" => "#{budget.id}", "name" => "Food"}
                    },
                    %{
                      "amount" => "12.00",
                      "budget" => %{"id" => "#{budget.id}", "name" => "Food"}
                    }
                  ]
                }
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{current_user: user})
  end
end
