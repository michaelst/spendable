defmodule SpendableWeb.Api.SessionController do
  use SpendableWeb, :api_controller

  alias Spendable.Accounts
  alias Spendable.Scope
  alias SpendableWeb.Api.Schemas.Errors
  alias SpendableWeb.Api.Schemas.Session
  alias SpendableWeb.Api.Schemas.SessionRequest

  tags(["session"])

  operation(:create,
    summary: "Sign in",
    description: "Exchanges an ID token from a native sign-in for an API token.",
    security: [],
    request_body: {"Credentials", "application/json", SessionRequest},
    responses: [
      created: {"Session", "application/json", Session},
      unauthorized: {"Errors", "application/json", Errors},
      unprocessable_entity: {"Errors", "application/json", Errors}
    ]
  )

  def create(conn, params) do
    with {:ok, user} <- sign_in(params["provider"], params["id_token"]),
         {:ok, api_token} <-
           Accounts.create_api_token(Scope.for_user(user), Map.take(params, ["device_name"])) do
      conn
      |> put_status(:created)
      |> json(Session.build(api_token))
    end
  end

  operation(:delete,
    summary: "Sign out",
    description: "Revokes the token the request was made with.",
    responses: [
      no_content: {"Signed out", "application/json", nil},
      unauthorized: {"Errors", "application/json", Errors}
    ]
  )

  def delete(conn, _params) do
    {:ok, _revoked} =
      Accounts.revoke_api_token(conn.assigns.current_scope, conn.assigns.current_api_token)

    send_resp(conn, :no_content, "")
  end

  defp sign_in("apple", id_token), do: Accounts.sign_in_with_apple(id_token)
  defp sign_in("google", id_token), do: Accounts.sign_in_with_google(id_token)
end
