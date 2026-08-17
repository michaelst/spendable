defmodule SpendableWeb.MCP.Tools.FundBudget do
  @moduledoc """
  Sets what one month puts into one budget, overriding the amount it usually funds itself with.

  Use this to deviate for a single month - "only 200 into groceries this time" - or to skip a
  month by funding it with zero. Every other month keeps the budget's usual amount. This moves
  money into the budget, which is what makes it different from `update_budget`'s `balance`: that
  records an adjustment to correct a figure, this records the month's funding.
  """
  use Anubis.Server.Component, type: :tool, annotations: %{readOnlyHint: false}

  import SpendableWeb.Utils.ToolReply

  alias Spendable.Budgets

  schema do
    field :budget_id, {:required, :string}, description: "The id of the budget to fund."

    field :amount, {:required, :string},
      description:
        "What this month should put into the budget. Zero skips the month, and the skip is recorded " <>
          "rather than left blank. Decimal string, e.g. \"200.00\"."

    field :month, :string,
      description: "Any date inside the month to fund, as YYYY-MM-DD. Defaults to the current month."
  end

  @impl true
  def execute(params, frame) do
    scope = frame.assigns.current_scope

    with {:ok, month} <- parse_month(params[:month]),
         {:ok, budget} <- Budgets.get_budget(scope, id: params.budget_id),
         {:ok, funding} <- Budgets.update_funding(scope, budget, month, params.amount),
         {:ok, funded} <- Budgets.get_budget(scope, id: budget.id) do
      reply(frame, %{
        funding: %{
          budget_id: funded.id,
          name: funded.name,
          month: Date.to_string(funding.month),
          amount: Decimal.to_string(funding.amount),
          balance: Decimal.to_string(funded.balance)
        }
      })
    else
      {:error, reason} -> reply_error(frame, reason)
    end
  end

  defp parse_month(nil), do: {:ok, Date.utc_today()}
  defp parse_month(month), do: Date.from_iso8601(month)
end
