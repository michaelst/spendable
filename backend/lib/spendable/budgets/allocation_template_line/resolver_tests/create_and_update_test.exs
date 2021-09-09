defmodule Spendable.Budgets.AllocationTemplateLine.Resolver.CreateAndUpdateTest do
  use Spendable.DataCase, async: true

  test "create allocation template line" do
    user = insert(:user)

    allocation_template = insert(:allocation_template, user: user)
    budget = insert(:budget, user: user)

    query = """
    mutation {
      createAllocationTemplateLine(
        budgetAllocationTemplateId: "#{allocation_template.id}"
        amount: "5"
        budgetId: "#{budget.id}"
      ) {
        id
        amount
        budget {
          id
        }
      }
    }
    """

    assert {:ok,
            %{
              data: %{
                "createAllocationTemplateLine" => %{"id" => id, "amount" => "5", "budget" => %{"id" => budget_id}}
              }
            }} = Absinthe.run(query, Spendable.Web.Schema, context: %{current_user: user})

    assert "#{budget.id}" == budget_id

    query = """
    mutation {
      updateAllocationTemplateLine(
        id: "#{id}"
        amount: "10"
      ) {
        amount
        budget {
          id
        }
      }
    }
    """

    assert {:ok,
            %{
              data: %{
                "updateAllocationTemplateLine" => %{"amount" => "10", "budget" => %{"id" => "#{budget.id}"}}
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{current_user: user})
  end
end
