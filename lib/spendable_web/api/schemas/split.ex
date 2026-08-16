defmodule SpendableWeb.Api.Schemas.Split do
  @moduledoc false
  require OpenApiSpex

  import SpendableWeb.Utils.Money

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "Split",
    description: "A saved division of a transaction across budgets. Amounts are decimal strings.",
    type: :object,
    properties: %{
      id: %Schema{type: :string},
      name: %Schema{type: :string},
      archived_at: %Schema{type: :string, format: :"date-time", nullable: true},
      split_lines: %Schema{
        type: :array,
        description: "Oldest first.",
        items: %Schema{
          type: :object,
          properties: %{
            id: %Schema{type: :string},
            amount: %Schema{type: :string},
            budget_id: %Schema{type: :string}
          },
          required: [:id, :amount, :budget_id]
        }
      }
    },
    required: [:id, :name, :split_lines]
  })

  def build(%Spendable.Budgets.Schemas.Split{} = split) do
    %__MODULE__{
      id: split.id,
      name: split.name,
      archived_at: split.archived_at,
      split_lines:
        Enum.map(
          split.split_lines,
          &%{id: &1.id, amount: amount(&1.amount), budget_id: &1.budget_id}
        )
    }
  end
end
