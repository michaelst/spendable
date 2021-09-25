defmodule Spendable.BudgetAllocation.GraphQLTests do
  use Spendable.DataCase, async: false

  test "create and update allocation" do
    user = insert(:user)
    other_user = insert(:user)

    transaction = insert(:transaction, user_id: user.id)
    budget = insert(:budget, user_id: user.id)

    query = """
    mutation {
      createBudgetAllocation(input: {
        amount: "5"
        budget: { id: #{budget.id} }
        transaction: { id: #{transaction.id} }
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
                "createBudgetAllocation" => %{
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
      updateBudgetAllocation(
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
              data: %{
                "updateBudgetAllocation" => %{
                  "result" => %{
                    "amount" => "10",
                    "budget" => %{"id" => "#{budget.id}"}
                  }
                }
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{actor: user})

    assert {:ok,
            %{
              data: %{"updateBudgetAllocation" => nil},
              errors: [
                %{
                  code: "not_found",
                  locations: [%{column: 3, line: 2}],
                  message: "could not be found",
                  path: ["updateBudgetAllocation"],
                  fields: [:id],
                  short_message: "could not be found",
                  vars: []
                }
              ]
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{actor: other_user})
  end

  test "delete allocation" do
    user = insert(:user)
    other_user = insert(:user)

    %{id: id} = insert(:budget_allocation, user_id: user.id)

    query = """
    mutation {
      deleteBudgetAllocation(id: #{id}) {
        result {
          id
        }
      }
    }
    """

    assert {:ok,
            %{
              data: %{"deleteBudgetAllocation" => nil},
              errors: [
                %{
                  code: "not_found",
                  locations: [%{column: 3, line: 2}],
                  message: "could not be found",
                  path: ["deleteBudgetAllocation"],
                  fields: [:id],
                  short_message: "could not be found",
                  vars: []
                }
              ]
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{actor: other_user})

    assert {:ok,
            %{
              data: %{
                "deleteBudgetAllocation" => %{
                  "result" => %{
                    "id" => "#{id}"
                  }
                }
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{actor: user})
  end
end
