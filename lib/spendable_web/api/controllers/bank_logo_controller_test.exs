defmodule SpendableWeb.Api.BankLogoControllerTest do
  use SpendableWeb.ConnCase, async: true

  alias Spendable.Accounts
  alias Spendable.Banks.Schemas.BankMember
  alias Spendable.Repo
  alias Spendable.Scope

  @png <<137, 80, 78, 71>>

  setup %{conn: conn} do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    {:ok, api_token} = Accounts.create_api_token(Scope.for_user(user), %{})

    {:ok, bank_member} =
      Repo.insert(%BankMember{
        user_id: user.id,
        external_id: Ecto.UUID.generate(),
        name: "Tartan Bank",
        provider: "Plaid",
        plaid_token: "access-sandbox-token",
        logo: Base.encode64(@png)
      })

    conn = put_req_header(conn, "authorization", "Bearer " <> api_token.token)

    %{conn: conn, user: user, bank_member: bank_member}
  end

  test "serves the logo as a cacheable image", %{conn: conn, bank_member: bank_member} do
    conn = get(conn, ~p"/api/banks/#{bank_member.id}/logo")

    assert response(conn, 200) == @png
    assert ["image/png" <> _charset] = get_resp_header(conn, "content-type")
    assert ["private, max-age=86400"] = get_resp_header(conn, "cache-control")
  end

  test "revalidates against the etag", %{conn: conn, bank_member: bank_member} do
    conn = get(conn, ~p"/api/banks/#{bank_member.id}/logo")
    [etag] = get_resp_header(conn, "etag")

    assert conn
           |> recycle()
           |> put_req_header("authorization", List.first(get_req_header(conn, "authorization")))
           |> put_req_header("if-none-match", etag)
           |> get(~p"/api/banks/#{bank_member.id}/logo")
           |> response(304)
  end

  test "a connection without a logo is not found", %{conn: conn, user: user} do
    {:ok, logoless} =
      Repo.insert(%BankMember{
        user_id: user.id,
        external_id: Ecto.UUID.generate(),
        name: "No Logo Bank",
        provider: "Plaid",
        plaid_token: "access-sandbox-token"
      })

    assert conn |> get(~p"/api/banks/#{logoless.id}/logo") |> response(404)
  end

  test "another user's logo is not found", %{conn: conn} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    {:ok, theirs} =
      Repo.insert(%BankMember{
        user_id: other_user.id,
        external_id: Ecto.UUID.generate(),
        name: "Theirs",
        provider: "Plaid",
        plaid_token: "access-sandbox-token",
        logo: Base.encode64(@png)
      })

    assert conn |> get(~p"/api/banks/#{theirs.id}/logo") |> response(404)
  end

  test "requires a token", %{conn: conn, bank_member: bank_member} do
    assert conn
           |> delete_req_header("authorization")
           |> get(~p"/api/banks/#{bank_member.id}/logo")
           |> json_response(401)
  end
end
