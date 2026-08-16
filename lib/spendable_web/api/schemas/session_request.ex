defmodule SpendableWeb.Api.Schemas.SessionRequest do
  @moduledoc false
  require OpenApiSpex

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "SessionRequest",
    description: "An ID token from a native sign-in, exchanged for an API token.",
    type: :object,
    properties: %{
      provider: %Schema{type: :string, enum: ["apple", "google"]},
      id_token: %Schema{type: :string},
      device_name: %Schema{
        type: :string,
        maxLength: 100,
        description: "Shown when managing signed-in devices."
      }
    },
    required: [:provider, :id_token],
    example: %{
      "provider" => "google",
      "id_token" => "eyJhbGciOiJSUzI1NiIsImtpZCI6IjEyMyJ9.eyJzdWIiOiI0MiJ9.signature",
      "device_name" => "iPhone"
    }
  })
end
