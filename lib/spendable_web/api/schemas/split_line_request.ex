defmodule SpendableWeb.Api.Schemas.SplitLineRequest do
  @moduledoc false
  require OpenApiSpex

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "SplitLineRequest",
    description: "A line to keep, update or add. Distinct from SplitLine because `id` is optional.",
    type: :object,
    properties: %{
      id: %Schema{type: :string, description: "Omit to add a new line."},
      amount: %Schema{type: :string},
      budget_id: %Schema{type: :string}
    },
    required: [:amount, :budget_id]
  })
end
