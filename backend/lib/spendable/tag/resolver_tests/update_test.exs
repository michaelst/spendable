defmodule Spendable.Tag.Resolver.UpdateTest do
  use Spendable.Web.ConnCase, async: true
  import Spendable.Factory

  test "update tag", %{conn: conn} do
    {user, token} = Spendable.TestUtils.create_user()
    tag = insert(:tag, user: user)

    query = """
      mutation {
        updateTag(id: #{tag.id} name: "new tag") {
          id
          name
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
               "updateTag" => %{
                 "id" => "#{tag.id}",
                 "name" => "new tag"
               }
             }
           } == response
  end
end
