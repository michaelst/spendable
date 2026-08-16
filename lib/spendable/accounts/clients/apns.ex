defmodule Spendable.Accounts.Clients.Apns do
  @moduledoc false

  # APNs rejects a provider token minted more than once every 20 minutes and honours one for an
  # hour, so it is signed once and reused rather than per push.
  @refresh_after_seconds 2_400

  def client() do
    middleware = [
      {Tesla.Middleware.BaseUrl, config()[:base_url]},
      Tesla.Middleware.JSON
    ]

    Tesla.client(middleware)
  end

  @doc """
  Sends one payload to one device. Returns `{:error, :not_configured}` where no signing key is
  set, so a machine without a `.p8` runs everything else unchanged.
  """
  def push(device_token, payload, headers) when is_binary(device_token) do
    case config()[:private_key] do
      key when is_binary(key) ->
        Tesla.post(client(), "/3/device/#{device_token}", payload,
          headers: [
            {"authorization", "bearer " <> provider_token(key)},
            {"apns-topic", config()[:topic]} | headers
          ]
        )

      nil ->
        {:error, :not_configured}
    end
  end

  defp provider_token(key) do
    now = System.system_time(:second)

    case :persistent_term.get({__MODULE__, :provider_token}, nil) do
      {token, issued_at} when now - issued_at < @refresh_after_seconds -> token
      _stale -> sign(key, now)
    end
  end

  defp sign(key, now) do
    signer = Joken.Signer.create("ES256", %{"pem" => key}, %{"kid" => config()[:key_id]})

    {:ok, token, _claims} =
      Joken.encode_and_sign(%{"iss" => config()[:team_id], "iat" => now}, signer)

    :persistent_term.put({__MODULE__, :provider_token}, {token, now})

    token
  end

  defp config(), do: Application.get_env(:spendable, __MODULE__)
end
