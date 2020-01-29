defmodule Spendable.Transaction.Resolver.UpdateTest do
  use Spendable.Web.ConnCase, async: true
  import Spendable.Factory

  alias Spendable.Banks.Category
  alias Spendable.Repo

  test "update", %{conn: conn} do
    {user, token} = Spendable.TestUtils.create_user()
    category_id = Repo.get_by!(Category, external_id: "22006001").id
    budget = insert(:budget, user_id: user.id)
    transaction = insert(:transaction, user_id: user.id)

    query = """
      mutation {
        updateTransaction(id: #{transaction.id}, name: "new name", categoryId: "#{category_id}", budgetId: "#{budget.id}") {
          id
          name
          budget {
            id
          }
          category {
            id
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
                 }
               }
             }
           } == response
  end
end
