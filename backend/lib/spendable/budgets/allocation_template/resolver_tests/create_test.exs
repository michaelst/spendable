defmodule Spendable.Budgets.AllocationTemplate.Resolver.CreateTest do
  use Spendable.Web.ConnCase, async: true
  import Spendable.Factory

  test "create budget template" do
    user = insert(:user)

    budget = insert(:budget, user: user)

    query = """
    mutation {
      createAllocationTemplate(
        name: "test budget template"
        lines: [
          {
            amount: "5"
            budgetId: "#{budget.id}"
          }
        ]
      ) {
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
                "createAllocationTemplate" => %{
                  "name" => "test budget template",
                  "lines" => [
                    %{
                      "amount" => "5.00",
                      "budget" => %{"id" => "#{budget.id}", "name" => "Food"}
                    }
                  ]
                }
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{current_user: user})
  end
end
