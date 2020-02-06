defmodule Spendable.Web.HttpRedirectTest do
  use Spendable.Web.ConnCase

  test "http redirect", %{conn: conn} do
    redirected_to =
      conn
      |> put_req_header("x-forwarded-proto", "http")
      |> get("/graphql")
      |> redirected_to(:moved_permanently)

    assert redirected_to == "https://spendable.dev/graphql"
  end
end
