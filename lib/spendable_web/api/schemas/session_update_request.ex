defmodule SpendableWeb.Api.Schemas.SessionUpdateRequest do
  @moduledoc false
  require OpenApiSpex

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "SessionUpdateRequest",
    description: "The device this token was issued to, so the server can push to it.",
    type: :object,
    properties: %{
      apns_token: %Schema{
        type: :string,
        pattern: ~r/\A[0-9a-f]+\z/i,
        minLength: 64,
        maxLength: 256,
        description: "The hex device token iOS handed the app."
      }
    },
    required: [:apns_token]
  })
end
