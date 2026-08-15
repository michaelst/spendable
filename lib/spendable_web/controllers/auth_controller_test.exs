defmodule SpendableWeb.AuthControllerTest do
  use SpendableWeb.ConnCase, async: true

  alias Spendable.Accounts
  alias Spendable.Accounts.Schemas.User

  test "GET /", %{conn: conn} do
    assert conn
           |> get("/")
           |> response(200) =~ "Sign in with Google"
  end

  test "callback", %{conn: conn} do
    auth = %Ueberauth.Auth{
      uid: "1",
      provider: :google,
      info: %Ueberauth.Auth.Info{
        nickname: "tester"
      }
    }

    conn =
      conn
      |> Plug.Test.init_test_session(%{})
      |> assign(:ueberauth_auth, auth)
      |> SpendableWeb.AuthController.callback(%{})

    assert response(conn, 302)

    assert {:ok, %User{id: "usr_" <> _uxid, provider: "google", external_id: "1"}} =
             conn |> Plug.Conn.get_session(:current_user_id) |> Accounts.get_user()
  end

  test "callback signs a returning user back into the same account", %{conn: conn} do
    {:ok, user} = Accounts.upsert_user_from_oauth(%{external_id: "2", provider: "google"})

    auth = %Ueberauth.Auth{uid: "2", provider: :google, info: %Ueberauth.Auth.Info{}}

    conn =
      conn
      |> Plug.Test.init_test_session(%{})
      |> assign(:ueberauth_auth, auth)
      |> SpendableWeb.AuthController.callback(%{})

    assert Plug.Conn.get_session(conn, :current_user_id) == user.id
  end

  test "DELETE /logout", %{conn: conn} do
    assert conn
           |> delete("/logout")
           |> response(302)
  end
end
