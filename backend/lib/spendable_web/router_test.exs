defmodule Spendable.Web.RouterTest do
  use Spendable.Web.ConnCase, async: true

  test "it works", %{conn: conn} do
    query = """
      query {
        currentUser {
          plaidLinkToken
        }
      }
    """

    conn
    |> post("/graphql", %{query: query})
    |> json_response(200)
  end
end
