defmodule SpendableWeb.BankLogoControllerTest do
  use SpendableWeb.ConnCase, async: true

  alias Spendable.Accounts
  alias Spendable.Banks.Schemas.BankMember
  alias Spendable.Repo

  @logo <<137, 80, 78, 71, 13, 10, 26, 10>>

  setup %{conn: conn} do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    {:ok, bank_member} =
      Repo.insert(%BankMember{
        user_id: user.id,
        external_id: Ecto.UUID.generate(),
        name: "Tartan Bank",
        provider: "Plaid",
        plaid_token: "access-sandbox-token",
        logo: Base.encode64(@logo)
      })

    conn =
      conn
      |> Plug.Test.init_test_session(%{})
      |> put_session(:current_user_id, user.id)

    %{conn: conn, bank_member: bank_member}
  end

  test "serves the logo as a png", %{conn: conn, bank_member: bank_member} do
    conn = get(conn, ~p"/banks/#{bank_member.id}/logo")

    assert response(conn, 200) == @logo
    assert response_content_type(conn, :png) =~ "image/png"
    assert get_resp_header(conn, "cache-control") == ["private, max-age=86400"]
  end

  test "answers 304 when the caller already has the logo", %{
    conn: conn,
    bank_member: bank_member
  } do
    etag =
      conn
      |> get(~p"/banks/#{bank_member.id}/logo")
      |> get_resp_header("etag")
      |> List.first()

    conn =
      conn
      |> put_req_header("if-none-match", etag)
      |> get(~p"/banks/#{bank_member.id}/logo")

    assert response(conn, 304) == ""
  end

  test "answers 404 for another user's bank", %{conn: conn} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    {:ok, theirs} =
      Repo.insert(%BankMember{
        user_id: other_user.id,
        external_id: Ecto.UUID.generate(),
        name: "Not Mine",
        provider: "Plaid",
        plaid_token: "access-sandbox-token",
        logo: Base.encode64(@logo)
      })

    assert conn |> get(~p"/banks/#{theirs.id}/logo") |> response(404) == ""
  end

  test "answers 404 when signed out", %{bank_member: bank_member} do
    conn = Plug.Test.init_test_session(build_conn(), %{})

    assert conn |> get(~p"/banks/#{bank_member.id}/logo") |> response(404) == ""
  end

  test "answers 404 when the bank has no logo", %{conn: conn, bank_member: bank_member} do
    {:ok, bank_member} = bank_member |> Ecto.Changeset.change(%{logo: nil}) |> Repo.update()

    assert conn |> get(~p"/banks/#{bank_member.id}/logo") |> response(404) == ""
  end
end
