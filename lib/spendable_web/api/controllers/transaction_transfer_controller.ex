defmodule SpendableWeb.Api.TransactionTransferController do
  use SpendableWeb, :api_controller

  alias OpenApiSpex.Schema
  alias Spendable.Transactions
  alias SpendableWeb.Api.Schemas.Errors
  alias SpendableWeb.Api.Schemas.Transaction
  alias SpendableWeb.Api.Schemas.TransferRequest

  tags ["transactions"]

  operation :create,
    operation_id: "createTransfer",
    summary: "Link two transactions as a transfer",
    description: """
    A transfer moves money between the user's own accounts rather than spending it, so the pair
    has to be one transaction leaving an account and one arriving in another. Both sides come
    back, with their allocations cleared onto Spendable where the opposite signs cancel.
    """,
    request_body: {"Transactions to link", "application/json", TransferRequest},
    responses: [
      ok: {"Both sides", "application/json", %Schema{type: :array, items: Transaction}},
      conflict: {"Errors", "application/json", Errors},
      not_found: {"Errors", "application/json", Errors},
      unprocessable_entity: {"Errors", "application/json", Errors}
    ]

  def create(conn, %{"transaction_ids" => [one_id, two_id]}) do
    scope = conn.assigns.current_scope

    with {:ok, one} <- Transactions.get_transaction(scope, id: one_id),
         {:ok, two} <- Transactions.get_transaction(scope, id: two_id),
         {:ok, {linked_one, linked_two}} <- Transactions.mark_as_transfer(scope, one, two) do
      json(conn, Enum.map([linked_one, linked_two], &Transaction.build/1))
    end
  end

  operation :delete,
    operation_id: "deleteTransfer",
    summary: "Unlink a transfer",
    description: "Both sides count toward budgets again. Their allocations stay where they are.",
    parameters: [id: [in: :path, type: :string, required: true]],
    responses: [
      ok: {"Transaction", "application/json", Transaction},
      conflict: {"Errors", "application/json", Errors},
      not_found: {"Errors", "application/json", Errors}
    ]

  def delete(conn, %{"id" => id}) do
    scope = conn.assigns.current_scope

    with {:ok, transaction} <- Transactions.get_transaction(scope, id: id),
         {:ok, removed} <- Transactions.remove_transfer(scope, transaction) do
      json(conn, Transaction.build(removed))
    end
  end
end
