defmodule Spendable.Auth.Guardian.KeyServer do
  use GenServer

  alias Spendable.Auth.Google

  @behaviour Guardian.Token.Jwt.SecretFetcher

  @impl Guardian.Token.Jwt.SecretFetcher
  def fetch_signing_secret(_mod, _opts), do: {:error, :secret_not_found}

  @impl Guardian.Token.Jwt.SecretFetcher
  def fetch_verifying_secret(_mod, %{"kid" => kid}, _opts) do
    case GenServer.call(__MODULE__, {:fetch_public_key, kid}) do
      {:ok, public_key} -> {:ok, JOSE.JWK.from_pem(public_key)}
      :error -> {:error, :secret_not_found}
    end
  end

  def fetch_verifying_secret(_mod, _headers, _opts), do: {:error, :secret_not_found}

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl GenServer
  def init(_opts) do
    {:ok, %{public_keys: nil}}
  end

  # Callbacks

  @impl GenServer
  def handle_call({:fetch_public_key, kid}, _from, %{public_keys: nil}) do
    {:ok, %{body: public_keys}} = Google.get_firebase_public_keys()

    {:reply, Map.fetch(public_keys, kid), %{public_keys: public_keys}}
  end

  def handle_call({:fetch_public_key, kid}, _from, %{public_keys: public_keys} = state) do
    {:reply, Map.fetch(public_keys, kid), state}
  end
end
