defmodule SpendableWeb.Api.Schemas.FinanceKitResult do
  @moduledoc false
  require OpenApiSpex

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "FinanceKitResult",
    description: "What a batch changed, and where to resume from.",
    type: :object,
    properties: %{
      applied: %Schema{
        type: :integer,
        description: "Rows changed. Lower than what was sent when a batch is replayed."
      },
      history_token: %Schema{type: :string}
    },
    required: [:applied, :history_token]
  })

  def build(%{applied: applied, history_token: history_token}) do
    %__MODULE__{applied: applied, history_token: history_token}
  end
end
