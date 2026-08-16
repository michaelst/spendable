defmodule SpendableWeb.Api.Schemas.ConnectRequest do
  @moduledoc false
  require OpenApiSpex

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "ConnectRequest",
    description: "The public token Plaid Link returns once the user has picked a bank.",
    type: :object,
    properties: %{public_token: %Schema{type: :string}},
    required: [:public_token]
  })
end
