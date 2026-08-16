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
      provider: %Schema{type: :string},
      bank_limit: %Schema{type: :integer, description: "How many banks the user may connect."}
    },
    required: [:id, :provider, :bank_limit]
  })

  def build(%Spendable.Accounts.Schemas.User{} = user) do
    %__MODULE__{
      id: user.id,
      image: user.image,
      provider: user.provider,
      bank_limit: user.bank_limit
    }
  end
end
