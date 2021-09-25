defmodule Spendable.BudgetAllocationTemplateLine.GraphQLTest do
  use Spendable.DataCase, async: false

  test "create/update budget allocation template line" do
    user = insert(:user)
    other_user = insert(:user)

    allocation_template = insert(:budget_allocation_template, user_id: user.id)
    budget = insert(:budget, user_id: user.id)

    query = """
    mutation {
      createBudgetAllocationTemplateLine(input: {
        budgetAllocationTemplate: { id: #{allocation_template.id} }
        amount: "5"
        budget: { id: #{budget.id} }
      }) {
        result {
          id
          amount
          budget {
            id
          }
        }
      }
    }
    """

    assert {:ok,
            %{
              data: %{
                "createBudgetAllocationTemplateLine" => %{
                  "result" => %{
                    "id" => id,
                    "amount" => "5",
                    "budget" => %{"id" => budget_id}
                  }
                }
              }
            }} = Absinthe.run(query, Spendable.Web.Schema, context: %{actor: user})

    assert "#{budget.id}" == budget_id

    query = """
    mutation {
      updateBudgetAllocationTemplateLine(
        id: "#{id}"
        input: { amount: "10" }
      ) {
        result {
          amount
          budget {
            id
          }
        }
      }
    }
    """

    assert {:ok,
            %{
              data: %{"updateBudgetAllocationTemplateLine" => nil},
              errors: [
                %{
                  code: "not_found",
                  fields: [:id],
                  locations: [%{column: 3, line: 2}],
                  message: "could not be found",
                  path: ["updateBudgetAllocationTemplateLine"],
                  short_message: "could not be found",
                  vars: []
                }
              ]
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{actor: other_user})

    assert {:ok,
            %{
              data: %{
                "updateBudgetAllocationTemplateLine" => %{
                  "result" => %{
                    "amount" => "10",
                    "budget" => %{"id" => "#{budget.id}"}
                  }
                }
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{actor: user})
  end

  test "delete budget allocation template line" do
    user = insert(:user)
    other_user = insert(:user)

    template = insert(:budget_allocation_template, user_id: user.id)
    budget = insert(:budget, user_id: user.id)

    line =
      insert(:budget_allocation_template_line,
        user_id: user.id,
        budget_id: budget.id,
        budget_allocation_template_id: template.id
      )

    query = """
    mutation {
      deleteBudgetAllocationTemplateLine(id: #{line.id}) {
        result {
          id
        }
      }
    }
    """

    assert {
             :ok,
             %{
               data: %{"deleteBudgetAllocationTemplateLine" => nil},
               errors: [
                 %{
                   code: "not_found",
                   locations: [%{column: 3, line: 2}],
                   message: "could not be found",
                   path: ["deleteBudgetAllocationTemplateLine"],
                   fields: [:id],
                   short_message: "could not be found",
                   vars: []
                 }
               ]
             }
           } == Absinthe.run(query, Spendable.Web.Schema, context: %{actor: other_user})

    assert {:ok,
            %{
              data: %{
                "deleteBudgetAllocationTemplateLine" => %{
                  "result" => %{
                    "id" => "#{line.id}"
                  }
                }
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{actor: user})
  end
end
