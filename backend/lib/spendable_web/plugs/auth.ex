defmodule Spendable.Plug.Auth do
  @moduledoc """
  If an authorization token is passed in the request this plug will add auth
  to context for absinthe.
  """

  import Plug.Conn

  alias Spendable.Auth.Guardian
  alias Spendable.User

  def init(opts), do: opts

  def call(conn, _opts \\ []) do
    case build_context(conn) do
      {:ok, context} ->
        Absinthe.Plug.put_options(conn, context: context)

      _nil ->
        conn
    end
  end

  defp build_context(conn) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, %User{} = user, _claims} <- Guardian.resource_from_token(token) do
      {:ok, %{current_user: user, actor: user}}
    end
  end
end
