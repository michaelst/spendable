defmodule Spendable.Transaction.Resolver.CreateTest do
  use Spendable.Web.ConnCase, async: true
  import Spendable.Factory

  alias Spendable.Repo

  test "create transaction" do
    user = insert(:user)
    budget = insert(:budget, user: user)
    tag_one = insert(:tag, user: user, name: "First tag")
    tag_two = insert(:tag, user: user, name: "Second tag")

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
          tagIds: ["#{tag_one.id}", "#{tag_two.id}"]
        ) {
          name
          reviewed
          allocations {
            amount
            budget {
              id
            }
          }
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
                  ],
                  "tags" => [
                    %{"id" => "#{tag_one.id}", "name" => "First tag"},
                    %{"id" => "#{tag_two.id}", "name" => "Second tag"}
                  ]
                }
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{current_user: user})
  end
end
