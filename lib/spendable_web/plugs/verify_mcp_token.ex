defmodule SpendableWeb.Plugs.VerifyMcpToken do
  @moduledoc false

  import Plug.Conn

  alias Spendable.OAuth
  alias Spendable.Scope

  def init(opts), do: opts

  def call(conn, _opts) do
    issuer = Application.get_env(:spendable, :issuer)

    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, user} <- OAuth.verify_access_token(token, "#{issuer}/mcp") do
      assign(conn, :current_scope, Scope.for_user(user))
    else
      _error ->
        # The metadata URL is how a client that has never seen this server discovers where to
        # authorize, so an anonymous call is answered with directions rather than just a refusal.
        conn
        |> put_resp_header(
          "www-authenticate",
          ~s(Bearer realm="mcp", resource_metadata="#{issuer}/.well-known/oauth-protected-resource/mcp")
        )
        |> send_resp(401, "")
        |> halt()
    end
  end
end
