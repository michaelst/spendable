defmodule SpendableWeb.Api.TransactionController do
  use SpendableWeb, :api_controller

  alias OpenApiSpex.Schema
  alias Spendable.Transactions
  alias SpendableWeb.Api.Schemas.Errors
  alias SpendableWeb.Api.Schemas.Transaction
  alias SpendableWeb.Api.Schemas.TransactionRequest

  @default_per_page 25
  @max_per_page 200

  tags ["transactions"]

  operation :index,
    operation_id: "listTransactions",
    summary: "List transactions",
    description: """
    Newest first. Reviewed and excluded transactions are hidden unless asked for, because the list
    is a queue of what still needs attention. A page shorter than `per_page` is the last one.
    """,
    parameters: [
      search: [in: :query, type: :string, description: "Matches on name or note."],
      page: [in: :query, type: %Schema{type: :integer, minimum: 1}],
      per_page: [in: :query, type: %Schema{type: :integer, minimum: 1, maximum: @max_per_page}],
      show_reviewed: [in: :query, type: :boolean],
      show_excluded: [in: :query, type: :boolean]
    ],
    responses: [
      ok: {"Transactions", "application/json", %Schema{type: :array, items: Transaction}},
      unauthorized: {"Errors", "application/json", Errors},
      unprocessable_entity: {"Errors", "application/json", Errors}
    ]

  def index(conn, params) do
    transactions =
      Transactions.list_transactions(conn.assigns.current_scope,
        search: params["search"],
        page: integer(params["page"]),
        per_page: per_page(params["per_page"]),
        show_reviewed: boolean(params["show_reviewed"]),
        show_excluded: boolean(params["show_excluded"])
      )

    json(conn, Enum.map(transactions, &Transaction.build/1))
  end

  operation :show,
    operation_id: "getTransaction",
    summary: "Get a transaction",
    parameters: [id: [in: :path, type: :string, required: true]],
    responses: [
      ok: {"Transaction", "application/json", Transaction},
      not_found: {"Errors", "application/json", Errors}
    ]

  def show(conn, %{"id" => id}) do
    with {:ok, transaction} <- Transactions.get_transaction(conn.assigns.current_scope, id: id) do
      json(conn, Transaction.build(transaction))
    end
  end

  operation :create,
    operation_id: "createTransaction",
    summary: "Create a transaction",
    description: "For money the user is recording themselves; synced activity arrives on its own.",
    request_body: {"Transaction", "application/json", TransactionRequest},
    responses: [
      created: {"Transaction", "application/json", Transaction},
      unprocessable_entity: {"Errors", "application/json", Errors}
    ]

  def create(conn, params) do
    with {:ok, transaction} <- Transactions.create_transaction(conn.assigns.current_scope, params) do
      conn
      |> put_status(:created)
      |> json(Transaction.build(transaction))
    end
  end

  operation :update,
    operation_id: "updateTransaction",
    summary: "Update a transaction",
    description: "The response carries the allocations the server settled on. Render those.",
    parameters: [id: [in: :path, type: :string, required: true]],
    request_body: {"Transaction", "application/json", TransactionRequest},
    responses: [
      ok: {"Transaction", "application/json", Transaction},
      not_found: {"Errors", "application/json", Errors},
      unprocessable_entity: {"Errors", "application/json", Errors}
    ]

  def update(conn, %{"id" => id} = params) do
    scope = conn.assigns.current_scope

    with {:ok, transaction} <- Transactions.get_transaction(scope, id: id),
         {:ok, updated} <-
           Transactions.update_transaction(scope, transaction, Map.delete(params, "id")) do
      json(conn, Transaction.build(updated))
    end
  end

  operation :delete,
    operation_id: "deleteTransaction",
    summary: "Delete a transaction",
    description: "Its allocations go with it.",
    parameters: [id: [in: :path, type: :string, required: true]],
    responses: [
      no_content: {"Deleted", "application/json", nil},
      not_found: {"Errors", "application/json", Errors}
    ]

  def delete(conn, %{"id" => id}) do
    scope = conn.assigns.current_scope

    with {:ok, transaction} <- Transactions.get_transaction(scope, id: id),
         {:ok, _deleted} <- Transactions.delete_transaction(scope, transaction) do
      send_resp(conn, :no_content, "")
    end
  end

  defp per_page(per_page) do
    per_page |> integer() |> Kernel.||(@default_per_page) |> min(@max_per_page)
  end

  # Query params arrive as strings; the spec has already rejected anything unparseable.
  defp integer(value) when is_binary(value), do: String.to_integer(value)
  defp integer(_value), do: nil

  defp boolean(value), do: value == "true"
end
