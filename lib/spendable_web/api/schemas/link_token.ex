defmodule SpendableWeb.Api.Schemas.LinkToken do
  @moduledoc false
  require OpenApiSpex

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "LinkToken",
    description: "Hand this to the Plaid Link SDK. Short-lived.",
    type: :object,
    properties: %{link_token: %Schema{type: :string}},
    required: [:link_token]
  })

  def build(link_token), do: %__MODULE__{link_token: link_token}
end
