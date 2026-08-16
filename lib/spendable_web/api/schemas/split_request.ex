defmodule SpendableWeb.Api.Schemas.SplitRequest do
  @moduledoc false
  require OpenApiSpex

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "SplitRequest",
    description: """
    Send the whole set of lines you want the split to end up with. A line with an `id` is kept and
    updated, one without is added, and any line left out is deleted.
    """,
    type: :object,
    properties: %{
      name: %Schema{type: :string},
      split_lines: %Schema{
        type: :array,
        items: %Schema{
          type: :object,
          properties: %{
            id: %Schema{type: :string, description: "Omit to add a new line."},
            amount: %Schema{type: :string},
            budget_id: %Schema{type: :string}
          },
          required: [:amount, :budget_id]
        }
      }
    },
    example: %{
      "name" => "Payday",
      "split_lines" => [%{"amount" => "-200.00", "budget_id" => "bgt_01j0rent"}]
    }
  })
end
