defmodule SpendableWeb.Api.Schemas.Errors do
  @moduledoc false
  require OpenApiSpex

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "Errors",
    description: "The shape every failed request comes back in.",
    type: :object,
    properties: %{
      errors: %Schema{
        type: :array,
        items: %Schema{
          type: :object,
          properties: %{
            code: %Schema{type: :string, description: "Machine-readable reason."},
            detail: %Schema{type: :string},
            source: %Schema{
              type: :object,
              description: "Present on validation errors, pointing at the offending field.",
              properties: %{pointer: %Schema{type: :string}}
            }
          },
          required: [:code, :detail]
        }
      }
    },
    required: [:errors]
  })
end
