defmodule SpendableWeb.Api.FinanceKitController do
  use SpendableWeb, :api_controller

  alias Spendable.Banks
  alias SpendableWeb.Api.Schemas.Errors
  alias SpendableWeb.Api.Schemas.FinanceKitChanges
  alias SpendableWeb.Api.Schemas.FinanceKitConnection
  alias SpendableWeb.Api.Schemas.FinanceKitResult

  tags ["banks"]

  operation :create,
    operation_id: "connectFinanceKit",
    summary: "Claim the connection Wallet reports into",
    description: """
    Idempotent. Call it once the user has authorized FinanceKit, and again to find out where the
    last read left off - the `history_token` here is what a refused batch has to be resent against.
    """,
    responses: [
      ok: {"FinanceKitConnection", "application/json", FinanceKitConnection},
      unauthorized: {"Errors", "application/json", Errors}
    ]

  def create(conn, _params) do
    with {:ok, member} <- Banks.upsert_finance_kit_member(conn.assigns.current_scope) do
      json(conn, FinanceKitConnection.build(member))
    end
  end

  operation :changes,
    operation_id: "applyFinanceKitChanges",
    summary: "Send what the device read out of Wallet",
    description: """
    Refused with 409 when `history_token_before` is not where the server thinks the device left
    off; re-read the token from `POST /api/banks/finance_kit` and resend from there. Replaying a
    batch that did land is safe - the accounts and charges dedupe on their external ids.
    """,
    parameters: [id: [in: :path, type: :string, required: true]],
    request_body: {"One batch of changes", "application/json", FinanceKitChanges},
    responses: [
      ok: {"FinanceKitResult", "application/json", FinanceKitResult},
      conflict: {"Errors", "application/json", Errors},
      not_found: {"Errors", "application/json", Errors},
      unprocessable_entity: {"Errors", "application/json", Errors}
    ]

  def changes(conn, %{"id" => id} = params) do
    scope = conn.assigns.current_scope

    with {:ok, member} <- Banks.get_bank_member(scope, id: id),
         {:ok, result} <- Banks.apply_finance_kit_changes(scope, member, params) do
      json(conn, FinanceKitResult.build(result))
    end
  end
end
