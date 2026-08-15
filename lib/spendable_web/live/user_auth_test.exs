defmodule SpendableWeb.Live.UserAuthTest do
  use SpendableWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias Spendable.Accounts

  test "sends a signed in user through to the page", %{conn: conn} do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    conn = conn |> Plug.Test.init_test_session(%{}) |> put_session(:current_user_id, user.id)

    assert {:ok, _view, _html} = live(conn, ~p"/budgets")
  end

  # The session outlives the user record, so a stale id lands back on the sign in page.
  test "sends a session for a deleted user back to sign in", %{conn: conn} do
    conn =
      conn
      |> Plug.Test.init_test_session(%{})
      |> put_session(:current_user_id, "usr_01M036GTQ48JXS0A2AXFNV6H5P")

    assert {:error, {:redirect, %{to: "/"}}} = live(conn, ~p"/budgets")
  end

  test "sends a visitor with no session back to sign in", %{conn: conn} do
    conn = Plug.Test.init_test_session(conn, %{})

    assert {:error, {:redirect, %{to: "/"}}} = live(conn, ~p"/budgets")
  end
end
