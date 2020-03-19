defmodule Spendable.Web.HttpRedirect do
  @behaviour Plug
  import Plug.Conn
  require Logger

  def init(opts), do: opts

  def call(conn, _params) do
    conn
    |> get_req_header("x-forwarded-proto")
    |> case do
      ["http"] ->
        conn
        |> put_resp_header("location", "https://spendable.dev#{Phoenix.Controller.current_path(conn)}")
        |> resp(:moved_permanently, "")
        |> halt()

      _result ->
        conn
    end
  end
end
