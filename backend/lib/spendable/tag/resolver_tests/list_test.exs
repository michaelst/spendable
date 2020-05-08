defmodule Spendable.Tag.Resolver.ListTest do
  use Spendable.Web.ConnCase, async: true
  import Spendable.Factory

  test "list tags", %{conn: conn} do
    {user, token} = Spendable.TestUtils.create_user()
    tag_one = insert(:tag, user: user, name: "First tag")
    tag_two = insert(:tag, user: user, name: "Second tag")

    query = """
      query {
        tags {
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
               "tags" => [
                 %{
                   "id" => "#{tag_one.id}",
                   "name" => "First tag"
                 },
                 %{
                   "id" => "#{tag_two.id}",
                   "name" => "Second tag"
                 }
               ]
             }
           } == response
  end
end
