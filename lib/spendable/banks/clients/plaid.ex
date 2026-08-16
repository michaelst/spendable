defmodule Spendable.Banks.Clients.Plaid do
  @moduledoc false

  def client() do
    middleware = [
      {Tesla.Middleware.BaseUrl, config()[:base_url]},
      Tesla.Middleware.JSON
    ]

    Tesla.client(middleware)
  end

  def exchange_public_token(public_token) do
    client()
    |> Tesla.post("/item/public_token/exchange", %{
      client_id: config()[:client_id],
      secret: config()[:secret_key],
      public_token: public_token
    })
  end

  def institution(id) do
    client()
    |> Tesla.post("/institutions/get_by_id", %{
      client_id: config()[:client_id],
      secret: config()[:secret_key],
      institution_id: id,
      country_codes: ["US"],
      options: %{
        include_optional_metadata: true
      }
    })
  end

  def item(token) do
    client()
    |> Tesla.post("/item/get", %{
      client_id: config()[:client_id],
      secret: config()[:secret_key],
      access_token: token
    })
  end

  def create_link_token(user_id, access_token \\ nil)

  def create_link_token(user_id, nil) do
    client()
    |> Tesla.post("/link/token/create", Map.put(link_token(user_id), :products, ["transactions"]))
  end

  def create_link_token(user_id, access_token) do
    # access_token is passed for existing items, for example to verify micro deposits
    # do not pass products with this request or it will fail.
    client()
    |> Tesla.post("/link/token/create", Map.put(link_token(user_id), :access_token, access_token))
  end

  def accounts(token) do
    client()
    |> Tesla.post("/accounts/get", %{
      client_id: config()[:client_id],
      secret: config()[:secret_key],
      access_token: token
    })
  end

  def account_transactions(token, account_id, %Date{} = start_date, opts \\ []) do
    count = opts[:count] || 500
    offset = opts[:offset] || 0

    client()
    |> Tesla.post("/transactions/get", %{
      client_id: config()[:client_id],
      secret: config()[:secret_key],
      access_token: token,
      start_date: start_date,
      end_date: Date.utc_today(),
      options: %{
        account_ids: [account_id],
        count: count,
        offset: offset
      }
    })
  end

  defp link_token(user_id) do
    Map.merge(
      %{
        client_id: config()[:client_id],
        client_name: "Spendable",
        country_codes: ["US"],
        language: "en",
        secret: config()[:secret_key],
        user: %{client_user_id: "#{user_id}"},
        # Follows the host the app is actually running on, so an item linked against a dev server
        # does not deliver its webhooks to production.
        webhook: "#{issuer()}/plaid/webhook"
      },
      redirect_uri()
    )
  end

  # Most large US banks only offer OAuth, which cannot return to the app without a redirect URI
  # that is both registered with Plaid and reachable as a universal link. A universal link has to
  # be https, so a local dev server sends none and gets the non-OAuth institutions only.
  defp redirect_uri() do
    case issuer() do
      "https://" <> _host = issuer -> %{redirect_uri: "#{issuer}/plaid-oauth"}
      _not_universal_linkable -> %{}
    end
  end

  defp issuer(), do: :spendable |> Application.get_env(:issuer) |> String.trim_trailing("/")

  defp config(), do: Application.get_env(:spendable, __MODULE__)
end
