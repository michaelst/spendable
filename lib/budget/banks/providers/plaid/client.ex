defmodule Plaid do
  def client() do
    middleware = [
      {Tesla.Middleware.BaseUrl, Application.get_env(:budget, Plaid)[:base_url]},
      Tesla.Middleware.JSON
    ]

    Tesla.client(middleware)
  end

  def exchange_public_token(public_token) do
    client()
    |> Tesla.post("/item/public_token/exchange", %{
      client_id: Application.get_env(:budget, Plaid)[:client_id],
      secret: Application.get_env(:budget, Plaid)[:secret_key],
      public_token: public_token
    })
  end

  def categories() do
    client() |> Tesla.post("/categories/get", %{})
  end
end
