defmodule Spendable.Tranasction.GraphQLTests do
  use Spendable.DataCase, async: false

  test "get transaction" do
    user = insert(:user)
    other_user = insert(:user)

    transaction = insert(:transaction, user_id: user.id)

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
    user = insert(:user)
    other_user = insert(:user)

    expense = insert(:transaction, user_id: user.id, amount: -20.24)

    insert(:transaction,
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
    user = insert(:user)
    budget = insert(:budget, user_id: user.id)

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
                        "amount" => "26.25",
                        "budget" => %{
                          "id" => "#{budget.id}"
                        }
                      },
                      %{
                        "amount" => "100.00",
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
    user = insert(:user)
    other_user = insert(:user)
    budget = insert(:budget, user_id: user.id)
    transaction = insert(:transaction, user_id: user.id)

    insert(:budget_allocation,
      transaction: transaction,
      budget: budget,
      amount: 25.24,
      user_id: user.id
    )

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
              {
                amount: "100"
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
                        "amount" => "26.25",
                        "budget" => %{
                          "id" => "#{budget.id}"
                        }
                      },
                      %{
                        "amount" => "100.00",
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
    user = insert(:user)
    other_user = insert(:user)

    transaction = insert(:transaction, user_id: user.id)

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
