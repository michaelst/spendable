defmodule SpendableWeb.Api.Schemas.Split do
  @moduledoc false
  require OpenApiSpex

  alias OpenApiSpex.Schema
  alias SpendableWeb.Api.Schemas.SplitLine

  OpenApiSpex.schema(%{
    title: "Split",
    description: "A saved division of a transaction across budgets. Amounts are decimal strings.",
    type: :object,
    properties: %{
      id: %Schema{type: :string},
      name: %Schema{type: :string},
      archived_at: %Schema{type: :string, format: :"date-time", nullable: true},
      split_lines: %Schema{type: :array, description: "Oldest first.", items: SplitLine}
    },
    required: [:id, :name, :split_lines]
  })

  def build(%Spendable.Budgets.Schemas.Split{} = split) do
    %__MODULE__{
      id: split.id,
      name: split.name,
      archived_at: split.archived_at,
      split_lines: Enum.map(split.split_lines, &SplitLine.build/1)
    }
  end
end
