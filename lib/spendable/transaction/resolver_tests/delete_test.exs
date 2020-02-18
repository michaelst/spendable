defmodule Spendable.Transaction.Resolver.DeleteTest do
  use Spendable.Web.ConnCase, async: true
  import Spendable.Factory

  test "delete transaction", %{conn: conn} do
    {user, token} = Spendable.TestUtils.create_user()

    transaction = insert(:transaction, user: user)

    query = """
    mutation {
      deleteTransaction(id: #{transaction.id}) {
        id
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
               "deleteTransaction" => %{
                 "id" => "#{transaction.id}"
               }
             }
           } == response
  end
end
