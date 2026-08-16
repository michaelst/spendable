defmodule SpendableWeb.OAuthController do
  use SpendableWeb, :controller

  alias Spendable.OAuth

  def token(conn, %{"grant_type" => "authorization_code"} = params) do
    params
    |> with_client_credentials(conn)
    |> OAuth.exchange_authorization_code()
    |> respond(conn)
  end

  def token(conn, %{"grant_type" => "refresh_token"} = params) do
    params
    |> with_client_credentials(conn)
    |> OAuth.exchange_refresh_token()
    |> respond(conn)
  end

  def token(conn, _params), do: error(conn, 400, "unsupported_grant_type")

  def register(conn, params) do
    case OAuth.register_client(params) do
      {:ok, client, secret} ->
        conn
        |> put_status(201)
        |> json(registration(client, secret))

      {:error, %Ecto.Changeset{}} ->
        error(conn, 400, "invalid_client_metadata")
    end
  end

  defp respond({:ok, tokens}, conn) do
    conn
    |> put_resp_header("cache-control", "no-store")
    |> json(tokens)
  end

  defp respond({:error, :invalid_client}, conn), do: error(conn, 401, "invalid_client")
  defp respond({:error, :invalid_grant}, conn), do: error(conn, 400, "invalid_grant")

  # Credentials arrive either as HTTP Basic auth (client_secret_basic) or in the body
  # (client_secret_post). Normalize both into the params the context reads.
  defp with_client_credentials(params, conn) do
    case Plug.BasicAuth.parse_basic_auth(conn) do
      {client_id, client_secret} ->
        Map.merge(params, %{"client_id" => client_id, "client_secret" => client_secret})

      :error ->
        params
    end
  end

  defp error(conn, status, error) do
    conn
    |> put_status(status)
    |> json(%{error: error})
  end

  defp registration(client, secret) do
    registration = %{
      client_id: client.id,
      client_id_issued_at: DateTime.to_unix(client.inserted_at),
      client_name: client.client_name,
      redirect_uris: client.redirect_uris,
      grant_types: client.grant_types,
      response_types: client.response_types,
      token_endpoint_auth_method: client.token_endpoint_auth_method,
      scope: client.scope
    }

    if secret, do: Map.put(registration, :client_secret, secret), else: registration
  end
end
