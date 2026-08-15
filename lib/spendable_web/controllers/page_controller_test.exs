defmodule SpendableWeb.PageControllerTest do
  use SpendableWeb.ConnCase, async: true

  test "GET /privacy-policy", %{conn: conn} do
    conn = get(conn, ~p"/privacy-policy")

    assert html_response(conn, 200) =~ "Privacy Policy"
  end
end
