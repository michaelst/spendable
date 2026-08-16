defmodule SpendableWeb.Api.BankMemberController do
  use SpendableWeb, :api_controller

  alias OpenApiSpex.Schema
  alias Spendable.Banks
  alias SpendableWeb.Api.Schemas.BankMember
  alias SpendableWeb.Api.Schemas.ConnectRequest
  alias SpendableWeb.Api.Schemas.Errors
  alias SpendableWeb.Api.Schemas.LinkToken

  tags ["banks"]

  operation :index,
    operation_id: "listBanks",
    summary: "List connections and their accounts",
    parameters: [search: [in: :query, type: :string, description: "Matches on institution name."]],
    responses: [
      ok: {"BankMembers", "application/json", %Schema{type: :array, items: BankMember}},
      unauthorized: {"Errors", "application/json", Errors}
    ]

  def index(conn, params) do
    members = Banks.list_bank_members(conn.assigns.current_scope, search: params["search"])

    json(conn, Enum.map(members, &BankMember.build/1))
  end

  operation :create,
    operation_id: "createBank",
    summary: "Finish connecting a bank",
    description: """
    Exchanges the public token Plaid Link returned. The accounts arrive on the first sync rather
    than in this response, so the connection comes back with none.
    """,
    request_body: {"Public token", "application/json", ConnectRequest},
    responses: [
      created: {"BankMember", "application/json", BankMember},
      conflict: {"Errors", "application/json", Errors},
      unprocessable_entity: {"Errors", "application/json", Errors}
    ]

  def create(conn, %{"public_token" => public_token}) do
    scope = conn.assigns.current_scope

    with {:ok, member} <- Banks.create_bank_member_from_public_token(scope, public_token) do
      conn
      |> put_status(:created)
      |> json(BankMember.build(member))
    end
  end

  operation :link_token,
    operation_id: "createLinkToken",
    summary: "Start connecting a bank",
    description: "Refused once the user is at their bank limit, before Plaid is called.",
    responses: [
      ok: {"LinkToken", "application/json", LinkToken},
      conflict: {"Errors", "application/json", Errors}
    ]

  def link_token(conn, _params) do
    with {:ok, token} <- Banks.get_link_token(conn.assigns.current_scope) do
      json(conn, LinkToken.build(token))
    end
  end

  operation :update_link_token,
    operation_id: "createUpdateLinkToken",
    summary: "Reopen an existing connection",
    description: "For a connection whose status is not CONNECTED, or to verify micro deposits.",
    parameters: [id: [in: :path, type: :string, required: true]],
    responses: [
      ok: {"LinkToken", "application/json", LinkToken},
      not_found: {"Errors", "application/json", Errors}
    ]

  def update_link_token(conn, %{"id" => id}) do
    scope = conn.assigns.current_scope

    with {:ok, member} <- Banks.get_bank_member(scope, id: id),
         {:ok, token} <- Banks.get_update_link_token(scope, member) do
      json(conn, LinkToken.build(token))
    end
  end

  operation :sync,
    operation_id: "syncBank",
    summary: "Pull two years of history",
    description: """
    Queues the work and returns immediately. There is no completion signal - refresh the lists to
    pick up whatever has landed.
    """,
    parameters: [id: [in: :path, type: :string, required: true]],
    responses: [
      accepted: {"Queued", "application/json", nil},
      not_found: {"Errors", "application/json", Errors}
    ]

  def sync(conn, %{"id" => id}) do
    scope = conn.assigns.current_scope

    with {:ok, member} <- Banks.get_bank_member(scope, id: id),
         {:ok, _job} <- Banks.queue_historical_sync(scope, member) do
      send_resp(conn, :accepted, "")
    end
  end
end
