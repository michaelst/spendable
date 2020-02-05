defmodule Spendable.User.Resolver.CurrentUserTest do
  use Spendable.Web.ConnCase, async: true
  import Spendable.Factory

  test "current user", %{conn: conn} do
    {user, token} = Spendable.TestUtils.create_user()

    insert(:bank_account, user: user, balance: 100)
    budget = insert(:budget, user: user)
    insert(:allocation, user: user, budget: budget, amount: -25.55)
    budget = insert(:budget, user: user)
    insert(:allocation, user: user, budget: budget, amount: 10)

    user
    |> Spendable.User.changeset(%{
      first_name: "Michael",
      last_name: "St Clair"
    })
    |> Spendable.Repo.update!()

    query = """
      query {
        currentUser {
          bankLimit
          spendable
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
                 "bankLimit" => 0,
                 "spendable" => "64.45"
               }
             }
           } == response
  end
end
