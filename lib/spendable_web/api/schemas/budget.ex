defmodule SpendableWeb.Api.Schemas.Budget do
  @moduledoc false
  require OpenApiSpex

  import SpendableWeb.Utils.Money

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "Budget",
    description: "An envelope money is divided into. Amounts are decimal strings.",
    type: :object,
    properties: %{
      id: %Schema{type: :string},
      name: %Schema{type: :string},
      type: %Schema{type: :string, enum: ["tracking", "envelope", "goal", "income"]},
      budgeted_amount: %Schema{type: :string, nullable: true},
      funding_amount: %Schema{
        type: :string,
        nullable: true,
        description: "What the budget puts into itself each month. Null means it does not fund itself."
      },
      balance: %Schema{
        type: :string,
        description: """
        What the fundings and allocations add up to, or the bank account's balance when assigned.
        """
      },
      rollover: %Schema{
        type: :boolean,
        description: """
        Whether the balance carries into next month. False means the month tops the budget back up
        to its funding amount instead, so an overspend does not follow it and leftover does not
        accumulate. Only an envelope can decline to roll over.
        """
      },
      archived_at: %Schema{type: :string, format: :"date-time", nullable: true}
    },
    required: [:id, :name, :type, :balance, :rollover]
  })

  def build(%Spendable.Budgets.Schemas.Budget{} = budget) do
    %__MODULE__{
      id: budget.id,
      name: budget.name,
      type: Atom.to_string(budget.type),
      budgeted_amount: amount(budget.budgeted_amount),
      funding_amount: amount(budget.funding_amount),
      rollover: budget.rollover,
      balance: amount(budget.balance),
      archived_at: budget.archived_at
    }
  end
end
