defmodule Spendable.Web.Controllers.WellKnownTest do
  use Spendable.Web.ConnCase

  test "apple app site association", %{conn: conn} do
    response =
      conn
      |> get("/.well-known/apple-app-site-association")
      |> json_response(200)

    assert response == %{"webcredentials" => %{"apps" => ["fiftysevenmedia.Spendable"]}}
  end
end
