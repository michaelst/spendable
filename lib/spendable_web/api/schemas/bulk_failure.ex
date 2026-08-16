defmodule SpendableWeb.Api.Schemas.BulkFailure do
  @moduledoc false
  require OpenApiSpex

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "BulkFailure",
    description: "One transaction a bulk change did not apply to, and why.",
    type: :object,
    properties: %{
      id: %Schema{type: :string},
      code: %Schema{type: :string}
    },
    required: [:id, :code]
  })

  def build(id, code), do: %__MODULE__{id: id, code: code}
end
