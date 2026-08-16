defmodule SpendableWeb.Api.BudgetController do
  use SpendableWeb, :api_controller

  alias OpenApiSpex.Schema
  alias Spendable.Budgets
  alias SpendableWeb.Api.Schemas.Budget
  alias SpendableWeb.Api.Schemas.BudgetRequest
  alias SpendableWeb.Api.Schemas.Errors

  tags ["budgets"]

  operation :index,
    operation_id: "listBudgets",
    summary: "List budgets",
    description: "Spendable first, then alphabetical. Archived budgets are left out.",
    parameters: [search: [in: :query, type: :string, description: "Matches on name."]],
    responses: [
      ok: {"Budgets", "application/json", %Schema{type: :array, items: Budget}},
      unauthorized: {"Errors", "application/json", Errors}
    ]

  def index(conn, params) do
    budgets = Budgets.list_budgets(conn.assigns.current_scope, search: params["search"])

    json(conn, Enum.map(budgets, &Budget.build/1))
  end

  operation :show,
    operation_id: "getBudget",
    summary: "Get a budget",
    parameters: [id: [in: :path, type: :string, required: true]],
    responses: [
      ok: {"Budget", "application/json", Budget},
      not_found: {"Errors", "application/json", Errors}
    ]

  def show(conn, %{"id" => id}) do
    with {:ok, budget} <- Budgets.get_budget(conn.assigns.current_scope, id: id) do
      json(conn, Budget.build(budget))
    end
  end

  operation :create,
    operation_id: "createBudget",
    summary: "Create a budget",
    request_body: {"Budget", "application/json", BudgetRequest},
    responses: [
      created: {"Budget", "application/json", Budget},
      unprocessable_entity: {"Errors", "application/json", Errors}
    ]

  def create(conn, params) do
    with {:ok, budget} <- Budgets.create_budget(conn.assigns.current_scope, params) do
      conn
      |> put_status(:created)
      |> json(Budget.build(budget))
    end
  end

  operation :update,
    operation_id: "updateBudget",
    summary: "Update a budget",
    description: "The response carries the recalculated balance, so render it rather than the request.",
    parameters: [id: [in: :path, type: :string, required: true]],
    request_body: {"Budget", "application/json", BudgetRequest},
    responses: [
      ok: {"Budget", "application/json", Budget},
      forbidden: {"Errors", "application/json", Errors},
      not_found: {"Errors", "application/json", Errors},
      unprocessable_entity: {"Errors", "application/json", Errors}
    ]

  def update(conn, %{"id" => id} = params) do
    scope = conn.assigns.current_scope

    with {:ok, budget} <- Budgets.get_budget(scope, id: id),
         {:ok, updated} <- Budgets.update_budget(scope, budget, Map.delete(params, "id")) do
      json(conn, Budget.build(updated))
    end
  end

  operation :delete,
    operation_id: "archiveBudget",
    summary: "Archive a budget",
    description: "Budgets are archived rather than deleted, so the history they hold survives.",
    parameters: [id: [in: :path, type: :string, required: true]],
    responses: [
      ok: {"Budget", "application/json", Budget},
      conflict: {"Errors", "application/json", Errors},
      not_found: {"Errors", "application/json", Errors}
    ]

  def delete(conn, %{"id" => id}) do
    scope = conn.assigns.current_scope

    with {:ok, budget} <- Budgets.get_budget(scope, id: id),
         {:ok, archived} <- Budgets.archive_budget(scope, budget) do
      json(conn, Budget.build(archived))
    end
  end
end
