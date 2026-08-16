defmodule SpendableWeb.MCP.Tools.ListBudgets do
  @moduledoc """
  Lists the user's budgets with their current balance and what they intend each to hold. A budget
  is an envelope money is assigned to; Spendable is the one holding whatever a transaction has not
  been allocated elsewhere. Archived budgets are never listed.
  """
  use Anubis.Server.Component, type: :tool, annotations: %{readOnlyHint: true}

  alias Anubis.Server.Response
  alias Spendable.Budgets

  schema do
    field :search, :string, description: "Only list budgets whose name contains this text."
  end

  @impl true
  def execute(params, frame) do
    budgets =
      frame.assigns.current_scope
      |> Budgets.list_budgets(search: params[:search])
      |> Enum.map(
        &%{
          id: &1.id,
          name: &1.name,
          type: &1.type,
          balance: Decimal.to_string(&1.balance),
          budgeted_amount: &1.budgeted_amount && Decimal.to_string(&1.budgeted_amount)
        }
      )

    {:reply, Response.structured(Response.tool(), %{budgets: budgets}), frame}
  end
end
