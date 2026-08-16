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
      type: %Schema{type: :string, enum: ["tracking", "envelope", "goal"]},
      budgeted_amount: %Schema{type: :string, nullable: true},
      balance: %Schema{
        type: :string,
        description: "What the allocations add up to, or the bank account's balance when assigned."
      },
      archived_at: %Schema{type: :string, format: :"date-time", nullable: true}
    },
    required: [:id, :name, :type, :balance]
  })

  def build(%Spendable.Budgets.Schemas.Budget{} = budget) do
    %__MODULE__{
      id: budget.id,
      name: budget.name,
      type: Atom.to_string(budget.type),
      budgeted_amount: amount(budget.budgeted_amount),
      balance: amount(budget.balance),
      archived_at: budget.archived_at
    }
  end
end
