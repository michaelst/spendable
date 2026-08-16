defmodule SpendableWeb.Api.Schemas.User do
  @moduledoc false
  require OpenApiSpex

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "User",
    description: "The signed-in user.",
    type: :object,
    properties: %{
      id: %Schema{type: :string},
      image: %Schema{type: :string, nullable: true},
      bank_limit: %Schema{type: :integer, description: "How many banks the user may connect."},
      identities: %Schema{
        type: :array,
        description: "The ways this account can be signed into.",
        items: %Schema{
          type: :object,
          properties: %{
            id: %Schema{type: :string},
            provider: %Schema{type: :string, enum: ["apple", "google"]}
          },
          required: [:id, :provider]
        }
      }
    },
    required: [:id, :bank_limit, :identities]
  })

  def build(%Spendable.Accounts.Schemas.User{} = user, identities) do
    %__MODULE__{
      id: user.id,
      image: user.image,
      bank_limit: user.bank_limit,
      identities: Enum.map(identities, &%{id: &1.id, provider: &1.provider})
    }
  end
end
