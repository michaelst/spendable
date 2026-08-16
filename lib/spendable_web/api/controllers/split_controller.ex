defmodule SpendableWeb.Api.SplitController do
  use SpendableWeb, :api_controller

  alias OpenApiSpex.Schema
  alias Spendable.Budgets
  alias SpendableWeb.Api.Schemas.Errors
  alias SpendableWeb.Api.Schemas.Split
  alias SpendableWeb.Api.Schemas.SplitRequest

  tags ["splits"]

  operation :index,
    operation_id: "listSplits",
    summary: "List splits",
    description: "Alphabetical, without their lines. Archived splits are left out.",
    parameters: [search: [in: :query, type: :string, description: "Matches on name."]],
    responses: [
      ok: {"Splits", "application/json", %Schema{type: :array, items: Split}},
      unauthorized: {"Errors", "application/json", Errors}
    ]

  def index(conn, params) do
    splits = Budgets.list_splits(conn.assigns.current_scope, search: params["search"])

    json(conn, Enum.map(splits, &Split.build/1))
  end

  operation :show,
    operation_id: "getSplit",
    summary: "Get a split and its lines",
    parameters: [id: [in: :path, type: :string, required: true]],
    responses: [
      ok: {"Split", "application/json", Split},
      not_found: {"Errors", "application/json", Errors}
    ]

  def show(conn, %{"id" => id}) do
    with {:ok, split} <- Budgets.get_split(conn.assigns.current_scope, id) do
      json(conn, Split.build(split))
    end
  end

  operation :create,
    operation_id: "createSplit",
    summary: "Create a split",
    request_body: {"Split", "application/json", SplitRequest},
    responses: [
      created: {"Split", "application/json", Split},
      unprocessable_entity: {"Errors", "application/json", Errors}
    ]

  def create(conn, params) do
    with {:ok, split} <- Budgets.create_split(conn.assigns.current_scope, params) do
      conn
      |> put_status(:created)
      |> json(Split.build(split))
    end
  end

  operation :update,
    operation_id: "updateSplit",
    summary: "Update a split",
    parameters: [id: [in: :path, type: :string, required: true]],
    request_body: {"Split", "application/json", SplitRequest},
    responses: [
      ok: {"Split", "application/json", Split},
      not_found: {"Errors", "application/json", Errors},
      unprocessable_entity: {"Errors", "application/json", Errors}
    ]

  def update(conn, %{"id" => id} = params) do
    scope = conn.assigns.current_scope

    with {:ok, split} <- Budgets.get_split(scope, id),
         {:ok, updated} <- Budgets.update_split(scope, split, Map.delete(params, "id")) do
      json(conn, Split.build(updated))
    end
  end

  operation :delete,
    operation_id: "archiveSplit",
    summary: "Archive a split",
    parameters: [id: [in: :path, type: :string, required: true]],
    responses: [
      ok: {"Split", "application/json", Split},
      conflict: {"Errors", "application/json", Errors},
      not_found: {"Errors", "application/json", Errors}
    ]

  def delete(conn, %{"id" => id}) do
    scope = conn.assigns.current_scope

    with {:ok, split} <- Budgets.get_split(scope, id),
         {:ok, archived} <- Budgets.archive_split(scope, split) do
      json(conn, Split.build(archived))
    end
  end
end
