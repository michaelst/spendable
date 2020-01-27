defmodule Spendable.User.Resolver.CurrentUserTest do
  use Spendable.Web.ConnCase, async: true

  test "current user", %{conn: conn} do
    {user, token} = Spendable.TestUtils.create_user()

    user
    |> Spendable.User.changeset(%{
      first_name: "Michael",
      last_name: "St Clair"
    })
    |> Spendable.Repo.update!()

    query = """
      query {
        currentUser {
          firstName
          lastName
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
               "currentUser" => %{
                 "firstName" => "Michael",
                 "lastName" => "St Clair"
               }
             }
           } == response
  end
end
