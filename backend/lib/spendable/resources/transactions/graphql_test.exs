defmodule Spendable.Tranasction.GraphQLTests do
  use Spendable.DataCase, async: false

  test "get transaction" do
    user = Factory.insert(Spendable.User)
    other_user = Factory.insert(Spendable.User)

    transaction = Factory.insert(Spendable.Transaction, user_id: user.id)

    query = """
    query {
      transaction(id: #{transaction.id}) {
        id
        name
        note
        amount
        date
        reviewed
      }
    }
    """

    assert {:ok,
            %{
              data: %{
                "transaction" => %{
                  "amount" => "#{transaction.amount}",
                  "date" => "#{transaction.date}",
                  "id" => "#{transaction.id}",
                  "name" => "test",
                  "note" => "some notes",
                  "reviewed" => false
                }
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{actor: user})

    assert {:ok,
            %{
              data: nil,
              errors: [
                %{
                  code: "not_found",
                  fields: [:id],
                  locations: [%{column: 3, line: 2}],
                  message: "could not be found",
                  path: ["transaction"],
                  short_message: "could not be found",
                  vars: []
                }
              ]
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{actor: other_user})
  end

  test "list transactions" do
    user = Factory.insert(Spendable.User)
    other_user = Factory.insert(Spendable.User)

    expense = Factory.insert(Spendable.Transaction, user_id: user.id, amount: -20.24)

    Factory.insert(Spendable.Transaction,
      user_id: other_user.id,
      amount: 3314.89,
      date: Date.utc_today()
    )

    query = """
      query {
        transactions(offset: 0, limit: 100) {
          results {
            id
            name
            amount
            date
            reviewed
          }
        }
      }
    """

    assert {:ok,
            %{
              data: %{
                "transactions" => %{
                  "results" => [
                    %{
                      "amount" => "#{expense.amount}",
                      "date" => "#{expense.date}",
                      "id" => "#{expense.id}",
                      "name" => "test",
                      "reviewed" => false
                    }
                  ]
                }
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{actor: user})
  end

  test "create transaction" do
    user = Factory.insert(Spendable.User)
    budget = Factory.insert(Spendable.Budget, user_id: user.id)

    query = """
      mutation {
        createTransaction(
          input: {
            name: "new name"
            amount: "126.25"
            date: "#{Date.utc_today()}"
            reviewed: true
            budgetAllocations: [
              {
                amount: "26.25"
                budget: { id: #{budget.id} }
              }
              {
                amount: "100"
                budget: { id: #{budget.id} }
              }
            ]
          }
        ) {
          result {
            name
            reviewed
            budgetAllocations {
              amount
              budget {
                id
              }
            }
          }
        }
      }
    """

    assert {:ok,
            %{
              data: %{
                "createTransaction" => %{
                  "result" => %{
                    "name" => "new name",
                    "reviewed" => true,
                    "budgetAllocations" => [
                      %{
                        "amount" => "100.00",
                        "budget" => %{
                          "id" => "#{budget.id}"
                        }
                      },
                      %{
                        "amount" => "26.25",
                        "budget" => %{
                          "id" => "#{budget.id}"
                        }
                      }
                    ]
                  }
                }
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{actor: user})
  end

  test "update transaction" do
    user = Factory.insert(Spendable.User)
    other_user = Factory.insert(Spendable.User)
    spendable = Factory.insert(Spendable.Budget, user_id: user.id, name: "Spendable")
    budget = Factory.insert(Spendable.Budget, user_id: user.id)
    transaction = Factory.insert(Spendable.Transaction, user_id: user.id, amount: 126.25)

    # creates spendable allocation
    query = """
      mutation {
        updateTransaction(
          id: #{transaction.id}
          input: {
            name: "new name"
            reviewed: true
          }
        ) {
          result {
            id
            name
            reviewed
            budgetAllocations {
              amount
              budget {
                id
              }
            }
          }
        }
      }
    """

    assert {:ok,
            %{
              data: %{
                "updateTransaction" => %{
                  "result" => %{
                    "id" => "#{transaction.id}",
                    "name" => "new name",
                    "reviewed" => true,
                    "budgetAllocations" => [
                      %{
                        "amount" => "126.25",
                        "budget" => %{
                          "id" => "#{spendable.id}"
                        }
                      }
                    ]
                  }
                }
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{actor: user})

    query = """
      mutation {
        updateTransaction(
          id: #{transaction.id}
          input: {
            name: "new name"
            reviewed: true
            budgetAllocations: [
              {
                amount: "26.25"
                budget: { id: #{budget.id} }
              }
            ]
          }
        ) {
          result {
            id
            name
            reviewed
            budgetAllocations {
              amount
              budget {
                id
              }
            }
          }
        }
      }
    """

    assert {:ok,
            %{
              data: %{
                "updateTransaction" => %{
                  "result" => %{
                    "id" => "#{transaction.id}",
                    "name" => "new name",
                    "reviewed" => true,
                    "budgetAllocations" => [
                      %{
                        "amount" => "100.00",
                        "budget" => %{
                          "id" => "#{spendable.id}"
                        }
                      },
                      %{
                        "amount" => "26.25",
                        "budget" => %{
                          "id" => "#{budget.id}"
                        }
                      }
                    ]
                  }
                }
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{actor: user})

    assert {:ok,
            %{
              data: %{"updateTransaction" => nil},
              errors: [
                %{
                  code: "not_found",
                  fields: [:id],
                  locations: [%{column: 5, line: 2}],
                  message: "could not be found",
                  path: ["updateTransaction"],
                  short_message: "could not be found",
                  vars: []
                }
              ]
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{actor: other_user})
  end

  test "delete transaction" do
    user = Factory.insert(Spendable.User)
    other_user = Factory.insert(Spendable.User)

    transaction = Factory.insert(Spendable.Transaction, user_id: user.id)

    query = """
    mutation {
      deleteTransaction(id: #{transaction.id}) {
        result {
          id
        }
      }
    }
    """

    assert {
             :ok,
             %{
               data: %{"deleteTransaction" => nil},
               errors: [
                 %{
                   code: "not_found",
                   fields: [:id],
                   locations: [%{column: 3, line: 2}],
                   message: "could not be found",
                   path: ["deleteTransaction"],
                   short_message: "could not be found",
                   vars: []
                 }
               ]
             }
           } == Absinthe.run(query, Spendable.Web.Schema, context: %{actor: other_user})

    assert {:ok,
            %{
              data: %{
                "deleteTransaction" => %{
                  "result" => %{
                    "id" => "#{transaction.id}"
                  }
                }
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{actor: user})
  end
end
