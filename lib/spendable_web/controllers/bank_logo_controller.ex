defmodule SpendableWeb.BankLogoController do
  use SpendableWeb, :controller

  alias Spendable.Accounts
  alias Spendable.Banks
  alias Spendable.Scope

  @doc """
  Serves an institution's logo as an image so pages can link to it instead of inlining it.

  The transactions list repeats the same handful of logos on every row, and a base64 data URI
  would ship each copy again on every render. A URL is fetched once and then cached. Caching is
  `private` because the logo is only reachable to the user who owns the connection.
  """
  def show(conn, %{"id" => id}) do
    with {:ok, user} <- Accounts.get_user(get_session(conn, :current_user_id)),
         {:ok, bank_member} <- Banks.get_bank_member(Scope.for_user(user), id: id),
         {:ok, logo} <- decode(bank_member.logo) do
      send_logo(conn, logo)
    else
      _no_logo -> send_resp(conn, 404, "")
    end
  end

  defp decode(logo) when is_binary(logo), do: Base.decode64(logo)
  defp decode(_logo), do: :error

  defp send_logo(conn, logo) do
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
end
