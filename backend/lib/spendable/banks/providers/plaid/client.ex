defmodule Plaid do
  def client() do
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

  def categories() do
    client() |> Tesla.post("/categories/get", %{})
  end

  def institution(id) do
    client()
    |> Tesla.post("/institutions/get_by_id", %{
      client_id: Application.get_env(:spendable, Plaid)[:client_id],
      secret: Application.get_env(:spendable, Plaid)[:secret_key],
      institution_id: id,
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

  def create_link_token(user_id, access_token \\ nil)

  def create_link_token(user_id, nil) do
    client()
    |> Tesla.post("/link/token/create", %{
      client_id: Application.get_env(:spendable, Plaid)[:client_id],
      client_name: "Spendable",
      country_codes: ["US"],
      language: "en",
      products: ["transactions"],
      secret: Application.get_env(:spendable, Plaid)[:secret_key],
      user: %{client_user_id: "#{user_id}"},
      webhook: "https://spendable.money/plaid/webhook"
    })
  end

  def create_link_token(user_id, access_token) do
    client()
    |> Tesla.post("/link/token/create", %{
      # access_token is passed for existing items, for example to verify micro deposits
      # do not pass products with this request or it will fail.
      access_token: access_token,
      client_id: Application.get_env(:spendable, Plaid)[:client_id],
      client_name: "Genesis Block",
      country_codes: ["US"],
      language: "en",
      secret: Application.get_env(:spendable, Plaid)[:secret_key],
      user: %{client_user_id: "#{user_id}"},
      webhook: "https://spendable.money/plaid/webhook"
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
