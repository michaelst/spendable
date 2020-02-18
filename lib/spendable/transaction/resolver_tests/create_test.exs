defmodule Spendable.Transaction.Resolver.CreateTest do
  use Spendable.Web.ConnCase, async: true
  import Spendable.Factory

  alias Spendable.Banks.Category
  alias Spendable.Repo

  test "create transaction", %{conn: conn} do
    {user, token} = Spendable.TestUtils.create_user()
    category_id = Repo.get_by!(Category, external_id: "22006001").id
    budget = insert(:budget, user: user)

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
                 ]
               }
             }
           } == response
  end
end
