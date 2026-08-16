defmodule SpendableWeb.Api.Schemas.Session do
  @moduledoc false
  require OpenApiSpex

  alias OpenApiSpex.Schema
  alias Spendable.Accounts.Schemas.ApiToken

  OpenApiSpex.schema(%{
    title: "Session",
    description: "An API token. The token itself is returned once and never again.",
    type: :object,
    properties: %{
      token: %Schema{type: :string},
      device_name: %Schema{type: :string, nullable: true},
      expires_at: %Schema{type: :string, format: :"date-time"}
    },
    required: [:token, :expires_at]
  })

  def build(%ApiToken{} = api_token) do
    %__MODULE__{
      token: api_token.token,
      device_name: api_token.device_name,
      expires_at: api_token.expires_at
    }
  end
end
