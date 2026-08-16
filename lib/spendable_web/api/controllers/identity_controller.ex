defmodule SpendableWeb.Api.IdentityController do
  use SpendableWeb, :api_controller

  alias Spendable.Accounts
  alias SpendableWeb.Api.Schemas.Errors
  alias SpendableWeb.Api.Schemas.Identity
  alias SpendableWeb.Api.Schemas.SessionRequest

  tags ["session"]

  operation :create,
    summary: "Add another way to sign in",
    description: """
    Attaches a second provider to the account making the request. Nothing about a person is stored
    that would let the app match them across providers, so this is the only way two sign-in
    methods reach one account - and it has to be done from inside it.
    """,
    request_body: {"Credentials", "application/json", SessionRequest},
    responses: [
      created: {"Identity", "application/json", Identity},
      unauthorized: {"Errors", "application/json", Errors},
      conflict: {"Errors", "application/json", Errors}
    ]

  def create(conn, params) do
    scope = conn.assigns.current_scope

    with {:ok, identity} <-
           Accounts.link_identity(scope, params["provider"], params["id_token"]) do
      conn
      |> put_status(:created)
      |> json(Identity.build(identity))
    end
  end

  operation :delete,
    summary: "Remove a way to sign in",
    description: "Refused for the last one, which would leave an account nobody can get back into.",
    parameters: [id: [in: :path, type: :string, required: true]],
    responses: [
      no_content: {"Removed", "application/json", nil},
      conflict: {"Errors", "application/json", Errors},
      not_found: {"Errors", "application/json", Errors}
    ]

  def delete(conn, %{"id" => id}) do
    scope = conn.assigns.current_scope

    with {:ok, identity} <- Accounts.get_identity(scope, id),
         {:ok, _removed} <- Accounts.unlink_identity(scope, identity) do
      send_resp(conn, :no_content, "")
    end
  end
end
