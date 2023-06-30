defmodule Spendable.Budget.GraphQLTests do
  use Spendable.DataCase, async: true

  test "get budget" do
    user = Factory.insert(Spendable.User)
    other_user = Factory.insert(Spendable.User)

    budget = Factory.insert(Spendable.Budget, user_id: user.id)

    transaction = Factory.insert(Spendable.Transaction, user_id: user.id)

    Factory.insert(Spendable.BudgetAllocation,
      user_id: user.id,
      budget_id: budget.id,
      transaction_id: transaction.id,
      amount: Decimal.new("-100")
    )

    query = """
    query {
      budget(id: "#{budget.id}") {
        id
        adjustment
        balance
        spent(month: "2021-10-01")
        spentByMonth(numberOfMonths: 2) {
          month
          spent
        }
      }
    }
    """

    this_month =
      Timex.now()
      |> Timex.beginning_of_month()
      |> Timex.to_date()
      |> to_string()

    last_month =
      Timex.now()
      |> Timex.shift(months: -1)
      |> Timex.beginning_of_month()
      |> Timex.to_date()
      |> to_string()

    assert {:ok,
            %{
              data: %{
                "budget" => %{
                  "id" => "#{budget.id}",
                  "adjustment" => "0.00",
                  "balance" => "-100.00",
                  "spent" => "0",
                  "spentByMonth" => [
                    %{
                      "month" => this_month,
                      "spent" => "-100.00"
                    },
                    %{
                      "month" => last_month,
                      "spent" => "0.00"
                    }
                  ]
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
    user = Factory.insert(Spendable.User)
    other_user = Factory.insert(Spendable.User)

    budget1 = Factory.insert(Spendable.Budget, user_id: user.id, name: "first")
    budget2 = Factory.insert(Spendable.Budget, user_id: user.id, name: "second")
    spendable = Factory.insert(Spendable.Budget, user_id: user.id, name: "Spendable")

    Factory.insert(Spendable.Budget, user_id: other_user.id)

    query = """
      query {
        budgets(sort: [{ field: NAME }]) {
          id
        }
      }
    """

    assert {:ok,
            %{
              data: %{
                "budgets" => [
                  %{
                    "id" => "#{spendable.id}"
                  },
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
    user = Factory.insert(Spendable.User)

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
    user = Factory.insert(Spendable.User)
    other_user = Factory.insert(Spendable.User)

    budget = Factory.insert(Spendable.Budget, user_id: user.id)
    transaction = Factory.insert(Spendable.Transaction, user_id: user.id)

    Factory.insert(Spendable.BudgetAllocation,
      user_id: user.id,
      budget_id: budget.id,
      transaction_id: transaction.id,
      amount: 10
    )

    doc = """
      mutation {
        updateBudget(id: #{budget.id}, input: { name: "new name", archivedAt: "2022-01-01T12:00:00" }) {
          result {
            id
            name
            balance
            archivedAt
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
                    "balance" => "10.00",
                    "archivedAt" => "2022-01-01T12:00:00"
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
    user = Factory.insert(Spendable.User)
    other_user = Factory.insert(Spendable.User)

    budget = Factory.insert(Spendable.Budget, user_id: user.id)

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
