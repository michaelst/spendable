defmodule Spendable.Transaction.Resolver.GetTest do
  use Spendable.Web.ConnCase, async: true
  import Spendable.Factory

  alias Spendable.Banks.Category
  alias Spendable.Repo

  test "get transaction", %{conn: conn} do
    {user, token} = Spendable.TestUtils.create_user()
    category_id = Repo.get_by!(Category, external_id: "22006001").id

    transaction = insert(:transaction, user_id: user.id, category_id: category_id)

    query = """
      query {
        transaction(id: #{transaction.id}) {
          id
          name
          note
          amount
          date
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
               "transaction" => %{
                 "amount" => "#{transaction.amount}",
                 "category" => %{"id" => "#{category_id}"},
                 "date" => "#{transaction.date}",
                 "id" => "#{transaction.id}",
                 "name" => "test",
                 "note" => "some notes"
               }
             }
           } == response
  end
end
