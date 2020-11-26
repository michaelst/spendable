defmodule Spendable.Budgets.Allocation.Resolver.CreateAndUpdateTest do
  use Spendable.DataCase, async: true
  import Spendable.Factory

  test "create and update allocation" do
    {user, _token} = Spendable.TestUtils.create_user()

    transaction = insert(:transaction, user: user)
    budget = insert(:budget, user: user)

    query = """
    mutation {
      createAllocation(
        amount: "5"
        budgetId: "#{budget.id}"
        transactionId: "#{transaction.id}"
      ) {
        id
        amount
        budget {
          id
        }
      }
    }
    """

    assert {:ok,
            %{
              data: %{
                "createAllocation" => %{
                  "id" => id,
                  "amount" => "5",
                  "budget" => %{"id" => budget_id}
                }
              }
            }} = Absinthe.run(query, Spendable.Web.Schema, context: %{current_user: user})

    assert "#{budget.id}" == budget_id

    query = """
    mutation {
      updateAllocation(
        id: "#{id}"
        amount: "10"
      ) {
        amount
        budget {
          id
        }
      }
    }
    """

    assert {:ok,
            %{
              data: %{
                "updateAllocation" => %{
                  "amount" => "10",
                  "budget" => %{"id" => "#{budget.id}"}
                }
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{current_user: user})
  end
end
