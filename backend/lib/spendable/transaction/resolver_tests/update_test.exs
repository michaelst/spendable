defmodule Spendable.Transaction.Resolver.UpdateTest do
  use Spendable.Web.ConnCase, async: true
  import Spendable.Factory

  alias Spendable.Repo

  test "update transaction" do
    user = insert(:user)
    budget = insert(:budget, user: user)
    transaction = insert(:transaction, user: user)
    allocation = insert(:allocation, transaction: transaction, budget: budget, amount: 25.24, user: user)

    query = """
      mutation {
        updateTransaction(
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
        ) {
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

  test "update tags" do
    user = insert(:user)
    transaction = insert(:transaction, user: user)
    tag_one = insert(:tag, user: user, name: "First tag")
    tag_two = insert(:tag, user: user, name: "Second tag")

    query = """
      mutation {
        updateTransaction(
          id: #{transaction.id}
          tagIds: ["#{tag_one.id}", "#{tag_two.id}"]
        ) {
          tags {
            id
            name
          }
        }
      }
    """

    assert {:ok,
            %{
              data: %{
                "updateTransaction" => %{
                  "tags" => [
                    %{"id" => "#{tag_one.id}", "name" => "First tag"},
                    %{"id" => "#{tag_two.id}", "name" => "Second tag"}
                  ]
                }
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{current_user: user})

    query = """
      mutation {
        updateTransaction(
          id: #{transaction.id}
          tagIds: []
        ) {
          tags {
            id
            name
          }
        }
      }
    """

    assert {:ok,
            %{
              data: %{
                "updateTransaction" => %{
                  "tags" => []
                }
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{current_user: user})
  end
end
