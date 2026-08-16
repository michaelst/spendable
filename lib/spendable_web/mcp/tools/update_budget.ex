defmodule SpendableWeb.MCP.Tools.UpdateBudget do
  @moduledoc """
  Changes a budget's name, type, budgeted amount, or balance. Setting `balance` states what the
  budget should read and records the adjustment that gets it there, leaving its transactions alone.
  Only the fields given are changed.
  """
  use Anubis.Server.Component, type: :tool, annotations: %{readOnlyHint: false}

  import SpendableWeb.Utils.ToolReply

  alias Spendable.Budgets

  schema do
    field :budget_id, {:required, :string}, description: "The id of the budget to change."
    field :name, :string, description: "What the budget is called."
    field :type, {:enum, [:envelope, :goal, :tracking]}, description: "Envelope, goal or tracking."
    field :budgeted_amount, :string, description: "Decimal string, e.g. \"250.00\"."
    field :balance, :string, description: "Decimal string the balance should read, e.g. \"40.00\"."
  end

  @impl true
  def execute(params, frame) do
    scope = frame.assigns.current_scope

    attrs =
      %{}
      |> put_present("name", params[:name])
      |> put_present("type", params[:type])
      |> put_present("budgeted_amount", params[:budgeted_amount])
      |> put_present("balance", params[:balance])

    with {:ok, budget} <- Budgets.get_budget(scope, id: params.budget_id),
         {:ok, budget} <- Budgets.update_budget(scope, budget, attrs) do
      reply(frame, %{
        budget: %{
          id: budget.id,
          name: budget.name,
          type: budget.type,
          balance: Decimal.to_string(budget.balance),
          budgeted_amount: budget.budgeted_amount && Decimal.to_string(budget.budgeted_amount)
        }
      })
    else
      {:error, reason} -> reply_error(frame, reason)
    end
  end

  defp put_present(attrs, _key, nil), do: attrs
  defp put_present(attrs, key, value), do: Map.put(attrs, key, value)
end
