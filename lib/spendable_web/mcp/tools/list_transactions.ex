defmodule SpendableWeb.MCP.Tools.ListTransactions do
  @moduledoc """
  Lists the user's transactions newest first, with how each one is allocated across budgets. A
  transaction is negative when money left the user and positive when it arrived, and is always
  fully allocated - whatever is not assigned elsewhere sits in the Spendable budget. Transactions
  the user has already reviewed, or excluded from spending, are left out unless asked for.
  """
  use Anubis.Server.Component, type: :tool, annotations: %{readOnlyHint: true}

  alias Anubis.Server.Response
  alias Spendable.Transactions

  schema do
    field :search, :string, description: "Only list transactions whose name or note contains this text."
    field :show_reviewed, :boolean, description: "Include transactions the user has already reviewed."
    field :show_excluded, :boolean, description: "Include transactions excluded from spending."
    field :page, :integer, description: "1-based page of results, for reading past the first page."
    field :per_page, :integer, description: "How many transactions to return, 25 by default and 100 at most."
  end

  @impl true
  def execute(params, frame) do
    transactions =
      frame.assigns.current_scope
      |> Transactions.list_transactions(
        search: params[:search],
        show_reviewed: params[:show_reviewed],
        show_excluded: params[:show_excluded],
        page: params[:page],
        per_page: per_page(params[:per_page])
      )
      |> Enum.map(
        &%{
          id: &1.id,
          name: &1.name,
          date: Date.to_iso8601(&1.date),
          amount: Decimal.to_string(&1.amount),
          note: &1.note,
          reviewed: &1.reviewed,
          excluded: &1.excluded,
          allocations:
            Enum.map(
              &1.budget_allocations,
              fn allocation ->
                %{budget_id: allocation.budget_id, amount: Decimal.to_string(allocation.amount)}
              end
            )
        }
      )

    {:reply, Response.structured(Response.tool(), %{transactions: transactions}), frame}
  end

  # An agent asking for a hundred thousand rows should get a page, not the whole table.
  defp per_page(nil), do: nil
  defp per_page(per_page), do: per_page |> max(1) |> min(100)
end
