defmodule Spendable.Transaction.Resolver.UpdateTest do
  use Spendable.Web.ConnCase, async: true

  alias Spendable.Transaction
  alias Spendable.Banks.Category
  alias Spendable.Repo

  test "update", %{conn: conn} do
    {user, token} = Spendable.TestUtils.create_user()
    category_id = Repo.get_by!(Category, external_id: "22006001").id

    transaction =
      %Transaction{}
      |> Transaction.changeset(%{
        user_id: user.id,
        amount: 10,
        name: "test",
        note: "some notes",
        date: Date.utc_today()
      })
      |> Repo.insert!()

    query = """
      mutation {
        updateTransaction(id: #{transaction.id}, name: "new name", categoryId: "#{category_id}") {
          id
          name
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
                 "category" => %{
                   "id" => "#{category_id}"
                 }
               }
             }
           } == response
  end
end
