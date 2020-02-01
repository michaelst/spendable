defmodule Spendable.Transaction.Resolver.UpdateTest do
  use Spendable.Web.ConnCase, async: true
  import Spendable.Factory

  alias Spendable.Banks.Category
  alias Spendable.Repo

  test "update transaction", %{conn: conn} do
    {user, token} = Spendable.TestUtils.create_user()
    category_id = Repo.get_by!(Category, external_id: "22006001").id
    budget = insert(:budget, user: user)
    transaction = insert(:transaction, user: user)

    query = """
      mutation {
        updateTransaction(
          id: #{transaction.id}
          name: "new name"
          categoryId: "#{category_id}"
          budgetId: "#{budget.id}"
          allocations: [
            {
              amount: "100"
              budgetId: "#{budget.id}"
            }
          ]
        ) {
          id
          name
          budget {
            id
          }
          category {
            id
          }
          allocations {
            amount
            budget {
              id
            }
          }
        }
      }
    """

    response =
      conn
      |> put_req_header("authorization", "Bearer #{token}")
      |> post("/graphql", %{query: query})
      |> json_response(200)

    assert %{
             "data" => %{
               "updateTransaction" => %{
                 "id" => "#{transaction.id}",
                 "name" => "new name",
                 "budget" => %{
                   "id" => "#{budget.id}"
                 },
                 "category" => %{
                   "id" => "#{category_id}"
                 },
                 "allocations" => [
                   %{
                     "amount" => "100.00",
                     "budget" => %{
                       "id" => "#{budget.id}"
                     }
                   }
                 ]
               }
             }
           } == response
  end
end
