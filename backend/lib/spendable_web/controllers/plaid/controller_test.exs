defmodule Spendable.Web.Controllers.PlaidTest do
  use Spendable.Web.ConnCase, async: true

  test "webhook", %{conn: conn} do
    user = Factory.insert(Spendable.User)

    conn
    |> post("/plaid/webhook", %{"item_id" => "bogus"})
    |> response(:not_found)

    member = Factory.insert(Spendable.BankMember, user_id: user.id, external_id: "webhook_test")

    data = %SyncMemberRequest{member_id: member.id} |> SyncMemberRequest.encode()

    PubSubMock
    |> expect(:publish, fn ^data, "spendable-dev.sync-member-request" ->
      TeslaHelper.response(status: 200)
    end)

    conn
    |> post("/plaid/webhook", %{"item_id" => "webhook_test"})
    |> response(:ok)

    conn
    |> post("/plaid/webhook", %{})
    |> response(:not_found)
  end
end
