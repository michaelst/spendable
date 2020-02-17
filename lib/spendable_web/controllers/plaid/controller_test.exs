defmodule Spendable.Web.Controllers.PlaidTest do
  use Spendable.Web.ConnCase, async: true
  import Spendable.Factory

  test "webhook", %{conn: conn} do
    {user, _token} = Spendable.TestUtils.create_user()

    conn
    |> post("/plaid/webhook", %{"item_id" => "bogus"})
    |> response(:not_found)

    member = insert(:bank_member, user: user, external_id: "webhook_test")

    conn
    |> post("/plaid/webhook", %{"item_id" => "webhook_test"})
    |> response(:ok)

    Spendable.TestUtils.assert_job(Spendable.Jobs.Banks.SyncMember, [member.id])

    conn
    |> post("/plaid/webhook", %{})
    |> response(:not_found)
  end
end
