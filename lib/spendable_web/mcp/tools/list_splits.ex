defmodule SpendableWeb.MCP.Tools.ListSplits do
  @moduledoc """
  Lists the user's splits with their lines. A split is a named set of lines - one budget and amount
  each - used to pre-fill how a transaction is divided, so a recurring purchase does not have to be
  allocated by hand every time. Archived splits are never listed.
  """
  use Anubis.Server.Component, type: :tool, annotations: %{readOnlyHint: true}

  import SpendableWeb.Utils.ToolReply

  alias Spendable.Budgets

  schema do
    field :search, :string, description: "Only list splits whose name contains this text."
  end

  @impl true
  def execute(params, frame) do
    splits =
      frame.assigns.current_scope
      |> Budgets.list_splits(search: params[:search])
      |> Enum.map(
        &%{
          id: &1.id,
          name: &1.name,
          lines:
            Enum.map(
              &1.split_lines,
              fn line -> %{budget_id: line.budget_id, amount: Decimal.to_string(line.amount)} end
            )
        }
      )

    reply(frame, %{splits: splits})
  end
end
