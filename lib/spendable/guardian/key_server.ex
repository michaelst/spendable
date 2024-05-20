defmodule Spendable.Guardian.KeyServer do
  @behaviour Guardian.Token.Jwt.SecretFetcher

  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl GenServer
  def init(_opts) do
    :ets.new(__MODULE__, [:named_table, :public])
    {:ok, nil}
  end

  @impl Guardian.Token.Jwt.SecretFetcher
  # coveralls-ignore-next-line not supported
  def fetch_signing_secret(_mod, _opts), do: {:error, :not_supported}

  @impl Guardian.Token.Jwt.SecretFetcher
  def fetch_verifying_secret(_mod, %{"kid" => kid}, _opts) do
    case lookup(kid) do
      {:ok, jwk} ->
        {:ok, jwk}

      :error ->
        load_public_keys()
        lookup(kid)
    end
  end

  defp lookup(kid) do
    case :ets.lookup(__MODULE__, kid) do
      [{^kid, key}] -> {:ok, key}
      [] -> :error
    end
  end

  defp load_public_keys() do
    {:ok, %{body: body}} = Tesla.get("https://www.googleapis.com/oauth2/v3/certs")
    %{"keys" => public_keys} = Jason.decode!(body)

    Enum.each(public_keys, fn %{"kid" => kid} = key ->
      :ets.insert(__MODULE__, {kid, JOSE.JWK.from(key)})
    end)
  end
end
