defmodule SpendableWeb.Utils.SendLogo do
  @moduledoc "Import this module rather than aliasing it."

  import Plug.Conn

  @doc """
  Serves an institution's logo as an image so pages can link to it instead of inlining it.

  The transactions list repeats the same handful of logos on every row, and a base64 data URI
  would ship each copy again on every render. A URL is fetched once and then cached. Caching is
  `private` because the logo is only reachable to the user who owns the connection.
  """
  def send_logo(conn, logo) do
    etag = ~s("#{Base.encode16(:crypto.hash(:md5, logo), case: :lower)}")

    conn =
      conn
      |> put_resp_content_type("image/png")
      |> put_resp_header("cache-control", "private, max-age=86400")
      |> put_resp_header("etag", etag)

    if etag in get_req_header(conn, "if-none-match"),
      do: send_resp(conn, 304, ""),
      else: send_resp(conn, 200, logo)
  end

  def decode_logo(logo) when is_binary(logo), do: Base.decode64(logo)
  def decode_logo(_logo), do: :error
end
