defmodule SpendableWeb.PageControllerTest do
  use SpendableWeb.ConnCase, async: true

  test "GET /privacy-policy", %{conn: conn} do
    conn = get(conn, ~p"/privacy-policy")

    assert html_response(conn, 200) =~ "Privacy Policy"
  end

  # The app claims this path as a universal link, so reaching the server at all means it was not
  # there to intercept.
  test "GET /plaid-oauth", %{conn: conn} do
    conn = get(conn, ~p"/plaid-oauth")

    assert html_response(conn, 200) =~ "Open Spendable on your phone"
  end
end
