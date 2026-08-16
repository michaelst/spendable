defmodule SpendableWeb.Api.TransactionBulkController do
  use SpendableWeb, :api_controller

  alias Spendable.Transactions
  alias SpendableWeb.Api.Schemas.BulkRequest
  alias SpendableWeb.Api.Schemas.BulkResult
  alias SpendableWeb.Api.Schemas.Errors

  tags ["transactions"]

  operation :update,
    summary: "Change several transactions at once",
    description: """
    Applied one at a time rather than all or nothing, so a transaction that has since been deleted
    does not cost the rest their change. Check `failed` before assuming the whole set landed.
    """,
    request_body: {"Change to apply", "application/json", BulkRequest},
    responses: [
      ok: {"BulkResult", "application/json", BulkResult},
      unauthorized: {"Errors", "application/json", Errors},
      unprocessable_entity: {"Errors", "application/json", Errors}
    ]

  def update(conn, %{"transaction_ids" => ids} = params) do
    scope = conn.assigns.current_scope

    json(conn, BulkResult.build(Enum.map(ids, &apply_change(scope, &1, params))))
  end

  operation :delete,
    summary: "Delete several transactions at once",
    request_body: {"Transactions to delete", "application/json", BulkRequest},
    responses: [
      ok: {"BulkResult", "application/json", BulkResult},
      unauthorized: {"Errors", "application/json", Errors},
      unprocessable_entity: {"Errors", "application/json", Errors}
    ]

  def delete(conn, %{"transaction_ids" => ids}) do
    scope = conn.assigns.current_scope

    results =
      Enum.map(ids, fn id ->
        with {:ok, transaction} <- Transactions.get_transaction(scope, id: id) do
          Transactions.delete_transaction(scope, transaction)
        else
          {:error, code} -> {:error, id, code}
        end
      end)

    json(conn, BulkResult.build(results))
  end

  defp apply_change(scope, id, params) do
    with {:ok, transaction} <- Transactions.get_transaction(scope, id: id),
         {:ok, updated} <- Transactions.update_transaction(scope, transaction, attrs(transaction, params)) do
      {:ok, updated}
    else
      {:error, %Ecto.Changeset{}} -> {:error, id, :invalid}
      {:error, code} -> {:error, id, code}
    end
  end

  # A budget_id means "spend the whole of this one from there", which depends on the transaction's
  # own amount, so the attrs are built per transaction rather than once for the batch.
  defp attrs(transaction, %{"budget_id" => budget_id} = params) when is_binary(budget_id) do
    allocation = %{"amount" => transaction.amount, "budget_id" => budget_id}

    params
    |> Map.take(["reviewed", "excluded"])
    |> Map.put("budget_allocations", [allocation])
  end

  defp attrs(_transaction, params), do: Map.take(params, ["reviewed", "excluded"])
end
