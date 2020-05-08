defmodule Spendable.Tag.Resolver.DeleteTest do
  use Spendable.Web.ConnCase, async: true
  import Spendable.Factory

  test "delete tag", %{conn: conn} do
    {user, token} = Spendable.TestUtils.create_user()

    tag = insert(:tag, user: user)

    query = """
    mutation {
      deleteTag(id: #{tag.id}) {
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
               "deleteTag" => %{
                 "id" => "#{tag.id}"
               }
             }
           } == response
  end
end
