defmodule SpendableWeb.Api.Schemas.BudgetSummary do
  @moduledoc false
  require OpenApiSpex

  import SpendableWeb.Utils.Money

  alias OpenApiSpex.Schema
  alias SpendableWeb.Api.Schemas.Budget

  OpenApiSpex.schema(%{
    title: "BudgetSummary",
    description: """
    Everything the budgets screen shows for one month. Presentation is the client's - this is the
    numbers behind it.
    """,
    type: :object,
    properties: %{
      month: %Schema{type: :string, format: :date},
      current_month: %Schema{
        type: :boolean,
        description: "Spendable, allocated and credit cards only apply to the current month."
      },
      spendable: %Schema{type: :string, description: "Synced money no budget has claimed."},
      allocated_total: %Schema{type: :string, description: "Budgeted across envelopes."},
      spent_total: %Schema{type: :string, description: "Spent across envelopes this month."},
      credit_card_balance: %Schema{type: :string},
      budgets: %Schema{type: :array, items: Budget},
      spent: %Schema{
        type: :object,
        description: "Spent this month, keyed by budget id. Every listed budget has an entry.",
        additionalProperties: %Schema{type: :string}
      },
      spent_by_month: %Schema{
        type: :array,
        description: "Newest first, for the month picker.",
        items: %Schema{
          type: :object,
          properties: %{
            month: %Schema{type: :string, format: :date},
            spent: %Schema{type: :string}
          },
          required: [:month, :spent]
        }
      }
    },
    required: [
      :month,
      :current_month,
      :spendable,
      :allocated_total,
      :spent_total,
      :credit_card_balance,
      :budgets,
      :spent,
      :spent_by_month
    ]
  })

  def build(fields) do
    %__MODULE__{
      month: fields.month,
      current_month: fields.current_month,
      spendable: amount(fields.spendable),
      allocated_total: amount(fields.allocated_total),
      spent_total: amount(fields.spent_total),
      credit_card_balance: amount(fields.credit_card_balance),
      budgets: Enum.map(fields.budgets, &Budget.build/1),
      spent: Map.new(fields.spent, fn {id, spent} -> {id, amount(spent)} end),
      spent_by_month: Enum.map(fields.spent_by_month, &%{month: &1.month, spent: amount(&1.spent)})
    }
  end
end
