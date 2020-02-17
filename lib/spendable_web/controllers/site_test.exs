defmodule Spendable.Web.Controllers.SiteTest do
  use Spendable.Web.ConnCase, async: true

  test "index", %{conn: conn} do
    conn
    |> get("/")
    |> response(200)

    conn
    |> get("/?email=test@example.com")
    |> response(200)
  end

  test "privacy policy", %{conn: conn} do
    conn
    |> get("/privacy-policy")
    |> response(200)
  end

  test "contact us", %{conn: conn} do
    conn
    |> get("/contact-us")
    |> response(200)
  end
end
