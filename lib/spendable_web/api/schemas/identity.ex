defmodule SpendableWeb.Api.Schemas.Identity do
  @moduledoc false
  require OpenApiSpex

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "Identity",
    description: "A way of signing into an account.",
    type: :object,
    properties: %{
      id: %Schema{type: :string},
      provider: %Schema{type: :string, enum: ["apple", "google"]}
    },
    required: [:id, :provider]
  })

  def build(%Spendable.Accounts.Schemas.UserIdentity{} = identity) do
    %__MODULE__{id: identity.id, provider: identity.provider}
  end
end
