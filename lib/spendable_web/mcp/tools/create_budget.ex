defmodule SpendableWeb.MCP.Tools.CreateBudget do
  @moduledoc """
  Creates a budget: an envelope reserves money for a purpose, a goal saves toward a target,
  tracking only records spending without reserving anything, and income records money arriving.
  `budgeted_amount` is what the user intends it to hold; `funding_amount` is what it puts into
  itself each month; `balance` is what it holds now, and setting it records an adjustment for the
  difference rather than inventing transactions.
  """
  use Anubis.Server.Component, type: :tool, annotations: %{readOnlyHint: false}

  import SpendableWeb.Utils.ToolReply

  alias Spendable.Budgets

  schema do
    field :name, {:required, :string}, description: "What the budget is called, e.g. \"Groceries\"."

    # Strings, not atoms: the value arrives from JSON and is compared before anything casts it.
    field :type, {:enum, ["envelope", "goal", "tracking", "income"]},
      description:
        "envelope reserves money for a purpose, goal saves toward a target, tracking records spending " <>
          "without reserving anything, income records money arriving. Defaults to envelope."

    field :budgeted_amount, :string,
      description:
        "What the user intends this budget to hold - the figure its balance is read against. It is a " <>
          "target on its own; use funding_amount to actually put money in. Decimal string, e.g. \"250.00\"."

    field :funding_amount, :string,
      description:
        "What this budget puts into itself at the start of every month, drawn from what is spendable. " <>
          "Setting it is what makes a budget fill on its own instead of being fed from a paycheck by " <>
          "hand, and the current month is funded straight away. Only an envelope or a goal can hold " <>
          "money, so it is ignored on tracking and income. Decimal string, e.g. \"250.00\"."

    field :rollover, :boolean,
      description:
        "Whether the balance carries into next month. False means each month tops the budget back up " <>
          "to its funding amount instead, so an overspend does not follow it into the next month and " <>
          "leftover does not pile up. Only an envelope can decline to roll over; everything else always " <>
          "does. Defaults to true."

    field :balance, :string,
      description:
        "What the budget should read right now, for a budget that already holds something. Spendable " <>
          "records the gap between this and what its transactions add up to as an adjustment, so this " <>
          "corrects a balance rather than moving money. Leave it out to start at zero. Decimal string, " <>
          "e.g. \"40.00\"."
  end

  @impl true
  def execute(params, frame) do
    attrs =
      %{"name" => params.name}
      |> put_present("type", params[:type])
      |> put_present("budgeted_amount", params[:budgeted_amount])
      |> put_present("funding_amount", params[:funding_amount])
      |> put_present("rollover", params[:rollover])
      |> put_present("balance", params[:balance])

    case Budgets.create_budget(frame.assigns.current_scope, attrs) do
      {:ok, budget} ->
        reply(frame, %{
          budget: %{
            id: budget.id,
            name: budget.name,
            type: budget.type,
            budgeted_amount: budget.budgeted_amount && Decimal.to_string(budget.budgeted_amount),
            funding_amount: budget.funding_amount && Decimal.to_string(budget.funding_amount),
            rollover: budget.rollover,
            balance: Decimal.to_string(budget.balance)
          }
        })

      {:error, changeset} ->
        reply_error(frame, changeset)
    end
  end

  defp put_present(attrs, _key, nil), do: attrs
  defp put_present(attrs, key, value), do: Map.put(attrs, key, value)
end
