defmodule SpendableWeb.PlaidControllerTest do
  use SpendableWeb.ConnCase, async: true

  alias Spendable.Accounts
  alias Spendable.Banks.Jobs.SyncMember
  alias Spendable.Banks.Schemas.BankMember
  alias Spendable.Repo

  setup do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    {:ok, bank_member} =
      Repo.insert(%BankMember{
        user_id: user.id,
        external_id: "webhook_test",
        name: "Plaid",
        provider: "Plaid",
        plaid_token: "access-sandbox-token"
      })

    %{bank_member: bank_member}
  end

  test "queues a sync for the item Plaid names", %{conn: conn, bank_member: bank_member} do
    conn = post(conn, ~p"/plaid/webhook", %{"item_id" => "webhook_test"})

    assert response(conn, 200)
    assert_enqueued(worker: SyncMember, args: %{bank_member_id: bank_member.id})
  end

  test "404s for an item we do not hold", %{conn: conn} do
    conn = post(conn, ~p"/plaid/webhook", %{"item_id" => "unknown"})

    assert response(conn, 404)
    refute_enqueued(worker: SyncMember)
  end

  test "404s when the payload names no item", %{conn: conn} do
    conn = post(conn, ~p"/plaid/webhook", %{})

    assert response(conn, 404)
  end
end
