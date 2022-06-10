defmodule Spendable.BudgetAllocationTemplate.GraphQLTests do
  use Spendable.DataCase, async: true

  test "budget allocation templates" do
    user = Factory.insert(Spendable.User)
    other_user = Factory.insert(Spendable.User)

    Factory.insert(Spendable.BudgetAllocationTemplate, user_id: user.id, name: "Paycheck")
    Factory.insert(Spendable.BudgetAllocationTemplate, user_id: user.id, name: "Taxes")
    Factory.insert(Spendable.BudgetAllocationTemplate, user_id: other_user.id)

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
    user = Factory.insert(Spendable.User)

    budget = Factory.insert(Spendable.Budget, user_id: user.id)

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
    user = Factory.insert(Spendable.User)
    other_user = Factory.insert(Spendable.User)

    budget = Factory.insert(Spendable.Budget, user_id: user.id)
    template = Factory.insert(Spendable.BudgetAllocationTemplate, user_id: user.id)

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
    user = Factory.insert(Spendable.User)
    other_user = Factory.insert(Spendable.User)

    template = Factory.insert(Spendable.BudgetAllocationTemplate, user_id: user.id)

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
