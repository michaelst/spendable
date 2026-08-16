defmodule SpendableWeb.Api.SessionController do
  use SpendableWeb, :api_controller

  alias Spendable.Accounts
  alias Spendable.Scope
  alias SpendableWeb.Api.Schemas.Errors
  alias SpendableWeb.Api.Schemas.Session
  alias SpendableWeb.Api.Schemas.SessionRequest
  alias SpendableWeb.Api.Schemas.SessionUpdateRequest

  tags(["session"])

  operation(:create,
    operation_id: "createSession",
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
    with {:ok, user} <- Accounts.sign_in_with_oauth(params["provider"], params["id_token"]),
         {:ok, api_token} <-
           Accounts.create_api_token(Scope.for_user(user), Map.take(params, ["device_name"])) do
      conn
      |> put_status(:created)
      |> json(Session.build(api_token))
    end
  end

  operation(:update,
    operation_id: "updateSession",
    summary: "Register this device for push",
    description: """
    Sends the APNs device token iOS issued the app. It is held against the token the request was
    made with, so signing out stops the pushes with it.
    """,
    request_body: {"Device token", "application/json", SessionUpdateRequest},
    responses: [
      no_content: {"Registered", "application/json", nil},
      unauthorized: {"Errors", "application/json", Errors},
      unprocessable_entity: {"Errors", "application/json", Errors}
    ]
  )

  def update(conn, %{"apns_token" => apns_token}) do
    scope = conn.assigns.current_scope

    with {:ok, _api_token} <-
           Accounts.register_apns_token(scope, conn.assigns.current_api_token, apns_token) do
      send_resp(conn, :no_content, "")
    end
  end

  operation(:delete,
    operation_id: "deleteSession",
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
end
