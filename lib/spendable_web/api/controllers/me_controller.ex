defmodule SpendableWeb.Api.MeController do
  use SpendableWeb, :api_controller

  alias SpendableWeb.Api.Schemas.Errors
  alias SpendableWeb.Api.Schemas.User

  tags(["session"])

  operation(:show,
    summary: "The signed-in user",
    responses: [
      ok: {"User", "application/json", User},
      unauthorized: {"Errors", "application/json", Errors}
    ]
  )

  def show(conn, _params) do
    json(conn, User.build(conn.assigns.current_scope.user))
  end
end
