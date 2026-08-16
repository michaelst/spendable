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
      email: %Schema{
        type: :string,
        nullable: true,
        description: "What ties a Google and an Apple sign-in to one account."
      },
      image: %Schema{type: :string, nullable: true},
      bank_limit: %Schema{type: :integer, description: "How many banks the user may connect."}
    },
    required: [:id, :bank_limit]
  })

  def build(%Spendable.Accounts.Schemas.User{} = user) do
    %__MODULE__{
      id: user.id,
      email: user.email,
      image: user.image,
      bank_limit: user.bank_limit
    }
  end
end
