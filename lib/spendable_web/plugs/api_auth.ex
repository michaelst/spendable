defmodule SpendableWeb.Plugs.ApiAuth do
  @moduledoc false
  @behaviour Plug

  import Plug.Conn

  alias Spendable.Accounts
  alias Spendable.Accounts.Schemas.ApiToken
  alias Spendable.Scope
  alias SpendableWeb.Api.FallbackController

  @impl Plug
  def init(opts), do: opts

  @impl Plug
  def call(conn, _opts) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, %ApiToken{user: user} = api_token} <- Accounts.authenticate_api_token(token) do
      conn
      |> assign(:current_scope, Scope.for_user(user))
      |> assign(:current_api_token, api_token)
    else
      _unauthenticated ->
        conn
        |> FallbackController.call({:error, :unauthenticated})
        |> halt()
    end
  end
end
