defmodule Spendable.Tranasction.GraphQLTests do
  use Spendable.DataCase, async: true

  test "get transaction" do
    IO.inspect("test")
    user = insert(:user)

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
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{current_user: user})
  end

  test "list transactions" do
    user = insert(:user)
    budget = insert(:budget, user_id: user.id)

    expense = insert(:transaction, user_id: user.id, amount: -20.24)
    insert(:allocation, user_id: user.id, budget: budget, transaction: expense, amount: -20.24)

    deposit =
      insert(:transaction,
        user_id: user.id,
        amount: 3314.89,
        date: Date.utc_today()
      )

    insert(:allocation, user_id: user.id, budget: budget, transaction: deposit, amount: 3314.89)

    query = """
      query {
        transactions(offset: 0) {
          id
          name
          note
          amount
          date
          allocations {
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
                "transactions" => [
                  %{
                    "allocations" => [
                      %{
                        "amount" => "#{Decimal.new("3314.89")}",
                        "budget" => %{"id" => "#{budget.id}"}
                      }
                    ],
                    "amount" => "#{deposit.amount}",
                    "date" => "#{deposit.date}",
                    "id" => "#{deposit.id}",
                    "name" => "test",
                    "note" => "some notes"
                  },
                  %{
                    "allocations" => [
                      %{
                        "amount" => "#{Decimal.new("-20.24")}",
                        "budget" => %{"id" => "#{budget.id}"}
                      }
                    ],
                    "amount" => "#{expense.amount}",
                    "date" => "#{expense.date}",
                    "id" => "#{expense.id}",
                    "name" => "test",
                    "note" => "some notes"
                  }
                ]
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{current_user: user})
  end

  test "create transaction" do
    user = insert(:user)
    budget = insert(:budget, user: user)

    query = """
      mutation {
        createTransaction(
          name: "new name"
          amount: "126.25"
          date: "#{Date.utc_today()}"
          reviewed: true
          allocations: [
            {
              amount: "26.25"
              budgetId: "#{budget.id}"
            }
            {
              amount: "100"
              budgetId: "#{budget.id}"
            }
          ]
        ) {
          name
          reviewed
          allocations {
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
                "createTransaction" => %{
                  "name" => "new name",
                  "reviewed" => true,
                  "allocations" => [
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
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{current_user: user})
  end

  test "update transaction" do
    user = insert(:user)
    budget = insert(:budget, user_id: user.id)
    transaction = insert(:transaction, user_id: user.id)
    allocation = insert(:allocation, transaction: transaction, budget: budget, amount: 25.24, user_id: user.id)

    query = """
      mutation {
        updateTransaction(input: {
          id: #{transaction.id}
          name: "new name"
          reviewed: true
          allocations: [
            {
              id: #{allocation.id}
              amount: "26.25"
              budgetId: "#{budget.id}"
            }
            {
              amount: "100"
              budgetId: "#{budget.id}"
            }
          ]
        }) {
          result {
            id
            name
            reviewed
            allocations {
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
                  "id" => "#{transaction.id}",
                  "name" => "new name",
                  "reviewed" => true,
                  "allocations" => [
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
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{current_user: user})
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

    assert {:ok,
            %{
              data: %{
                "deleteTransaction" => %{
                  "result" => nil
                }
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{current_user: other_user})

    assert {:ok,
            %{
              data: %{
                "deleteTransaction" => %{
                  "result" => %{
                    "id" => "#{transaction.id}"
                  }
                }
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{current_user: user})
  end
end
