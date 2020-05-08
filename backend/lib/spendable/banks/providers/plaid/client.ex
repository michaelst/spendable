defmodule Plaid do
  def client do
    middleware = [
      {Tesla.Middleware.BaseUrl, Application.get_env(:spendable, Plaid)[:base_url]},
      Tesla.Middleware.JSON
    ]

    Tesla.client(middleware)
  end

  def exchange_public_token(public_token) do
    client()
    |> Tesla.post("/item/public_token/exchange", %{
      client_id: Application.get_env(:spendable, Plaid)[:client_id],
      secret: Application.get_env(:spendable, Plaid)[:secret_key],
      public_token: public_token
    })
  end

  def categories do
    client() |> Tesla.post("/categories/get", %{})
  end

  def institution(id) do
    client()
    |> Tesla.post("/institutions/get_by_id", %{
      institution_id: id,
      public_key: Application.get_env(:spendable, Plaid)[:public_key],
      options: %{
        include_optional_metadata: true
      }
    })
  end

  def item(token) do
    client()
    |> Tesla.post("/item/get", %{
      client_id: Application.get_env(:spendable, Plaid)[:client_id],
      secret: Application.get_env(:spendable, Plaid)[:secret_key],
      access_token: token
    })
  end

  def create_public_token(token) do
    client()
    |> Tesla.post("/item/public_token/create", %{
      client_id: Application.get_env(:spendable, Plaid)[:client_id],
      secret: Application.get_env(:spendable, Plaid)[:secret_key],
      access_token: token
    })
  end

  def accounts(token) do
    client()
    |> Tesla.post("/accounts/get", %{
      client_id: Application.get_env(:spendable, Plaid)[:client_id],
      secret: Application.get_env(:spendable, Plaid)[:secret_key],
      access_token: token
    })
  end

  def account_transactions(token, account_id, opts \\ []) do
    count = opts[:count] || 500
    offset = opts[:offset] || 0

    client()
    |> Tesla.post("/transactions/get", %{
      client_id: Application.get_env(:spendable, Plaid)[:client_id],
      secret: Application.get_env(:spendable, Plaid)[:secret_key],
      access_token: token,
      start_date: Date.utc_today() |> Date.add(-92),
      end_date: Date.utc_today(),
      options: %{
        account_ids: [account_id],
        count: count,
        offset: offset
      }
    })
  end
end
