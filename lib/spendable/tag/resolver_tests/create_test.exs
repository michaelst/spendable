defmodule Spendable.Tag.Resolver.CreateTest do
  use Spendable.Web.ConnCase, async: true

  test "create tag", %{conn: conn} do
    {_user, token} = Spendable.TestUtils.create_user()

    query = """
      mutation {
        createTag(name: "new tag") {
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
               "createTag" => %{
                 "name" => "new tag"
               }
             }
           } == response
  end
end
