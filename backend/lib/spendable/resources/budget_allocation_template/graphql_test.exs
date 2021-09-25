defmodule Spendable.BudgetAllocationTemplate.GraphQLTests do
  use Spendable.DataCase, async: false

  test "budget allocation templates" do
    user = insert(:user)
    other_user = insert(:user)

    insert(:budget_allocation_template, user_id: user.id, name: "Paycheck")
    insert(:budget_allocation_template, user_id: user.id, name: "Taxes")
    insert(:budget_allocation_template, user_id: other_user.id)

    query = """
      query {
        budgetAllocationTemplates(sort: [{ field: NAME }]) {
          name
        }
      }
    """

    assert {:ok,
            %{
              data: %{
                "budgetAllocationTemplates" => [
                  %{
                    "name" => "Paycheck"
                  },
                  %{
                    "name" => "Taxes"
                  }
                ]
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{actor: user})
  end

  test "create budget allocation template" do
    user = insert(:user)

    budget = insert(:budget, user_id: user.id)

    query = """
    mutation {
      createBudgetAllocationTemplate(input: {
        name: "test budget template"
        budgetAllocationTemplateLines: [
          {
            amount: "5"
            budget: { id: #{budget.id} }
          }
        ]
      }) {
        result {
          name
          budgetAllocationTemplateLines {
            amount
            budget {
              id
              name
            }
          }
        }
      }
    }
    """

    assert {:ok,
            %{
              data: %{
                "createBudgetAllocationTemplate" => %{
                  "result" => %{
                    "name" => "test budget template",
                    "budgetAllocationTemplateLines" => [
                      %{
                        "amount" => "5.00",
                        "budget" => %{"id" => "#{budget.id}", "name" => "Food"}
                      }
                    ]
                  }
                }
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{actor: user})
  end

  test "update budget allocation template" do
    user = insert(:user)
    other_user = insert(:user)

    budget = insert(:budget, user_id: user.id)
    template = insert(:budget_allocation_template, user_id: user.id)

    query = """
      mutation {
        updateBudgetAllocationTemplate(
          id: #{template.id},
          input: {
            name: "new name"
            budgetAllocationTemplateLines: [
              {
                amount: "10"
                budget: { id: #{budget.id} }
              }
              {
                amount: "12"
                budget: { id: #{budget.id} }
              }
            ]
          }
        ) {
          result {
            id
            name
            budgetAllocationTemplateLines {
              amount
              budget {
                id
                name
              }
            }
          }
        }
      }
    """

    assert {:ok,
            %{
              data: %{
                "updateBudgetAllocationTemplate" => %{
                  "result" => %{
                    "id" => "#{template.id}",
                    "name" => "new name",
                    "budgetAllocationTemplateLines" => [
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
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{actor: user})

    assert {:ok,
            %{
              data: %{"updateBudgetAllocationTemplate" => nil},
              errors: [
                %{
                  code: "not_found",
                  fields: [:id],
                  locations: [%{column: 5, line: 2}],
                  message: "could not be found",
                  path: ["updateBudgetAllocationTemplate"],
                  short_message: "could not be found",
                  vars: []
                }
              ]
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{actor: other_user})
  end

  test "delete budget" do
    user = insert(:user)
    other_user = insert(:user)

    template = insert(:budget_allocation_template, user_id: user.id)

    query = """
    mutation {
      deleteBudgetAllocationTemplate(id: #{template.id}) {
        result {
          id
        }
      }
    }
    """

    assert {
             :ok,
             %{
               data: %{"deleteBudgetAllocationTemplate" => nil},
               errors: [
                 %{
                   code: "not_found",
                   locations: [%{column: 3, line: 2}],
                   message: "could not be found",
                   path: ["deleteBudgetAllocationTemplate"],
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
                "deleteBudgetAllocationTemplate" => %{
                  "result" => %{
                    "id" => "#{template.id}"
                  }
                }
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{actor: user})
  end
end
