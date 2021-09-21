defmodule Spendable.Budget.GraphQLTests do
  use Spendable.DataCase, async: true

  test "get budget" do
    user = insert(:user)
    other_user = insert(:user)

    budget = insert(:budget, user_id: user.id)

    query = """
    query {
      budget(id: "#{budget.id}") {
        id
      }
    }
    """

    assert {:ok,
            %{
              data: %{
                "budget" => %{
                  "id" => "#{budget.id}"
                }
              }
            }} ==
             Absinthe.run(query, Spendable.Web.Schema, context: %{actor: user})

    assert {:ok,
            %{
              data: nil,
              errors: [
                %{
                  code: "not_found",
                  locations: [%{column: 3, line: 2}],
                  message: "could not be found",
                  path: ["budget"],
                  fields: [:id],
                  short_message: "could not be found",
                  vars: []
                }
              ]
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{actor: other_user})
  end

  test "list budgets" do
    user = insert(:user)
    other_user = insert(:user)

    budget1 = insert(:budget, user_id: user.id, name: "first")
    budget2 = insert(:budget, user_id: user.id, name: "second")
    insert(:budget, user_id: other_user.id)

    query = """
      query {
        budgets {
          id
        }
      }
    """

    assert {:ok,
            %{
              data: %{
                "budgets" => [
                  %{
                    "id" => "#{budget1.id}"
                  },
                  %{
                    "id" => "#{budget2.id}"
                  }
                ]
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{actor: user})
  end

  test "create budget" do
    user = insert(:user)

    query = """
      mutation {
        createBudget(input: { name: "test budget", adjustment: "0.05" }) {
          result {
            name
            balance
          }
        }
      }
    """

    assert {:ok,
            %{
              data: %{
                "createBudget" => %{
                  "result" => %{
                    "name" => "test budget",
                    "balance" => "0.05"
                  }
                }
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{actor: user})
  end

  test "update budget" do
    user = insert(:user)
    other_user = insert(:user)

    budget = insert(:budget, user_id: user.id)
    insert(:budget_allocation, user_id: user.id, budget_id: budget.id, amount: 10)

    doc = """
      mutation {
        updateBudget(id: #{budget.id}, input: { name: "new name" }) {
          result {
            id
            name
            balance
          }
        }
      }
    """

    assert {:ok,
            %{
              data: %{"updateBudget" => nil},
              errors: [
                %{
                  code: "not_found",
                  fields: [:id],
                  locations: [%{column: 5, line: 2}],
                  message: "could not be found",
                  path: ["updateBudget"],
                  short_message: "could not be found",
                  vars: []
                }
              ]
            }} == Absinthe.run(doc, Spendable.Web.Schema, context: %{actor: other_user})

    assert {:ok,
            %{
              data: %{
                "updateBudget" => %{
                  "result" => %{
                    "id" => "#{budget.id}",
                    "name" => "new name",
                    "balance" => "10.00"
                  }
                }
              }
            }} == Absinthe.run(doc, Spendable.Web.Schema, context: %{actor: user})

    doc = """
      mutation {
        updateBudget(id: #{budget.id}, input: { name: "new name", adjustment: "0.05" }) {
          result {
            id
            name
            balance
          }
        }
      }
    """

    assert {:ok,
            %{
              data: %{
                "updateBudget" => %{
                  "result" => %{
                    "id" => "#{budget.id}",
                    "name" => "new name",
                    "balance" => "10.05"
                  }
                }
              }
            }} == Absinthe.run(doc, Spendable.Web.Schema, context: %{actor: user})

    doc = """
      mutation {
        updateBudget(id: #{budget.id}, input: { name: "new name", adjustment: "-10.00" }) {
          result {
            id
            name
            balance
          }
        }
      }
    """

    assert {:ok,
            %{
              data: %{
                "updateBudget" => %{
                  "result" => %{
                    "id" => "#{budget.id}",
                    "name" => "new name",
                    "balance" => "0.00"
                  }
                }
              }
            }} == Absinthe.run(doc, Spendable.Web.Schema, context: %{actor: user})
  end

  test "delete budget" do
    user = insert(:user)
    other_user = insert(:user)

    budget = insert(:budget, user_id: user.id)

    query = """
    mutation {
      deleteBudget(id: #{budget.id}) {
        result {
          id
        }
      }
    }
    """

    assert {
             :ok,
             %{
               data: %{"deleteBudget" => nil},
               errors: [
                 %{
                   code: "not_found",
                   locations: [%{column: 3, line: 2}],
                   message: "could not be found",
                   path: ["deleteBudget"],
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
                "deleteBudget" => %{
                  "result" => %{
                    "id" => "#{budget.id}"
                  }
                }
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{actor: user})
  end
end
