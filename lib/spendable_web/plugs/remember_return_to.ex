defmodule SpendableWeb.Plugs.RememberReturnTo do
  @moduledoc false

  import Phoenix.Controller, only: [current_path: 1]
  import Plug.Conn

  def init(opts), do: opts

  @doc """
  Remembers where a signed-out visitor was headed, so signing in finishes what they came to do
  instead of dropping them on the budgets page. Only ever a path this app produced, never a URL
  from the request, so it cannot be used to bounce someone somewhere else.
  """
  def call(conn, _opts) do
    if get_session(conn, "current_user_id") do
      conn
    else
      put_session(conn, "return_to", current_path(conn))
    end
  end
end
