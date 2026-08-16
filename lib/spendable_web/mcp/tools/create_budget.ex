defmodule SpendableWeb.MCP.Tools.CreateBudget do
  @moduledoc """
  Creates a budget: an envelope reserves money for a purpose, a goal saves toward a target, and
  tracking only records spending without reserving anything. `budgeted_amount` is what the user
  intends it to hold; `balance` is what it holds now, and setting it records an adjustment for the
  difference rather than inventing transactions.
  """
  use Anubis.Server.Component, type: :tool, annotations: %{readOnlyHint: false}

  import SpendableWeb.Utils.ToolReply

  alias Spendable.Budgets

  schema do
    field :name, {:required, :string}, description: "What the budget is called."
    field :type, {:enum, [:envelope, :goal, :tracking]}, description: "Defaults to envelope."
    field :budgeted_amount, :string, description: "Decimal string, e.g. \"250.00\"."
    field :balance, :string, description: "Decimal string the balance should read, e.g. \"40.00\"."
  end

  @impl true
  def execute(params, frame) do
    attrs =
      %{"name" => params.name}
      |> put_present("type", params[:type])
      |> put_present("budgeted_amount", params[:budgeted_amount])
      |> put_present("balance", params[:balance])

    case Budgets.create_budget(frame.assigns.current_scope, attrs) do
      {:ok, budget} ->
        reply(frame, %{
          budget: %{
            id: budget.id,
            name: budget.name,
            type: budget.type,
            budgeted_amount: budget.budgeted_amount && Decimal.to_string(budget.budgeted_amount)
          }
        })

      {:error, changeset} ->
        reply_error(frame, changeset)
    end
  end

  defp put_present(attrs, _key, nil), do: attrs
  defp put_present(attrs, key, value), do: Map.put(attrs, key, value)
end
