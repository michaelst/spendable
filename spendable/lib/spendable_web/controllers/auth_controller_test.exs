defmodule SpendableWeb.AuthControllerTest do
  use SpendableWeb.ConnCase, async: true

  import Hammox

  alias Coverbot.Resources.User

  test "GET /login", %{conn: conn} do
    assert conn
           |> get("/login")
           |> response(200) =~ "Sign in with GitHub"
  end

  test "callback", %{conn: conn} do
    TeslaMock
    |> expect(:call, fn %{
                          method: :post,
                          url: "https://api.stripe.com/v1/customers",
                          headers: [
                            {"authorization",
                             "Basic c2tfdGVzdF81MU5LNUlZQ3ZUWEhjb2lieXRBaGJqVVA3UjlnMkRDM1VnYTlTNEMyWEtRa3dRT0VocVltZmV2ejFCd1ZkeUJla2xnU3lLMjdHMm1KRmt1VWdNajVJVU8yTDAweWtnSTlSVEg6"},
                            {"content-type", "application/x-www-form-urlencoded"}
                          ]
                        },
                        _opts ->
      TeslaHelper.response(status: 200, body: %{"id" => "cus_O6cBHQ9MQ6MEUr"})
    end)

    auth = %Ueberauth.Auth{
      uid: 1,
      provider: :github,
      info: %Ueberauth.Auth.Info{
        nickname: "tester"
      }
    }

    assert conn
           |> Plug.Test.init_test_session(%{})
           |> assign(:ueberauth_auth, auth)
           |> SpendableWeb.AuthController.callback(%{})
           |> response(302)

    assert {:ok, %{github_username: "tester"}} = Coverbot.Api.get(User, github_id: 1)
  end

  test "DELETE /logout", %{conn: conn} do
    assert conn
           |> delete("/logout")
           |> response(302)
  end
end
