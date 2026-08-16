defmodule SpendableWeb.Api.MeController do
  use SpendableWeb, :api_controller

  alias Spendable.Accounts
  alias SpendableWeb.Api.Schemas.Errors
  alias SpendableWeb.Api.Schemas.User

  tags ["session"]

  operation :show,
    operation_id: "getCurrentUser",
    summary: "The signed-in user",
    description: "Carries the sign-in methods on the account, so the client can offer to add one.",
    responses: [
      ok: {"User", "application/json", User},
      unauthorized: {"Errors", "application/json", Errors}
    ]

  def show(conn, _params) do
    scope = conn.assigns.current_scope

    json(conn, User.build(scope.user, Accounts.list_identities(scope)))
  end
end
