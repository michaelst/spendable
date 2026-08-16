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
    field :name, :string, description: "What the budget is called, e.g. \"Groceries\"."

    # Strings, not atoms: the value arrives from JSON and is compared before anything casts it.
    field :type, {:enum, ["envelope", "goal", "tracking"]},
      description:
        "envelope reserves money for a purpose, goal saves toward a target, tracking records spending " <>
          "without reserving anything."

    field :budgeted_amount, :string,
      description:
        "What the user intends this budget to hold - the figure its balance is read against. It is a " <>
          "target, not money moved in, so it never changes the balance. Decimal string, e.g. \"250.00\"."

    field :balance, :string,
      description:
        "What the budget should read after this call. Spendable records the gap between this and what " <>
          "its transactions add up to as an adjustment, so this corrects a balance rather than moving " <>
          "money, and it leaves every transaction alone. Decimal string, e.g. \"40.00\"."
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
