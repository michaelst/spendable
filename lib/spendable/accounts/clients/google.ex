defmodule Spendable.Accounts.Clients.Google do
  @moduledoc false

  def client() do
    middleware = [
      {Tesla.Middleware.BaseUrl, config()[:base_url]},
      Tesla.Middleware.JSON
    ]

    Tesla.client(middleware)
  end

  def certs() do
    Tesla.get(client(), "/oauth2/v3/certs")
  end

  defp config(), do: Application.get_env(:spendable, __MODULE__)
end
