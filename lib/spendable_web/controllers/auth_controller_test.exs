defmodule SpendableWeb.AuthControllerTest do
  use SpendableWeb.ConnCase, async: true

  alias Spendable.User

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

    assert conn
           |> Plug.Test.init_test_session(%{})
           |> assign(:ueberauth_auth, auth)
           |> SpendableWeb.AuthController.callback(%{})
           |> response(302)

    assert {:ok, %{provider: "google"}} = Spendable.Api.get(User, external_id: "1")
  end

  test "DELETE /logout", %{conn: conn} do
    assert conn
           |> delete("/logout")
           |> response(302)
  end
end
