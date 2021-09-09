defmodule Spendable.Transaction.Resolver.CreateTest do
  use Spendable.Web.ConnCase, async: true

  alias Spendable.Repo

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
end
