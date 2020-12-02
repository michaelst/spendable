defmodule Spendable.Transaction.Resolver.CreateTest do
  use Spendable.Web.ConnCase, async: true
  import Spendable.Factory

  alias Spendable.Banks.Category
  alias Spendable.Repo

  test "create transaction" do
    user = Spendable.TestUtils.create_user()
    category_id = Repo.get_by!(Category, external_id: "22006001").id
    budget = insert(:budget, user: user)
    tag_one = insert(:tag, user: user, name: "First tag")
    tag_two = insert(:tag, user: user, name: "Second tag")

    query = """
      mutation {
        createTransaction(
          name: "new name"
          amount: "126.25"
          date: "#{Date.utc_today()}"
          categoryId: "#{category_id}"
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
          category {
            id
          }
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
                  "category" => %{
                    "id" => "#{category_id}"
                  },
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
