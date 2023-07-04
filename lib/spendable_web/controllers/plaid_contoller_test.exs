defmodule SpendableWeb.PlaidControllerTest do
  use SpendableWeb.ConnCase, async: true

  alias Spendable.Factory

  test "webhook", %{conn: conn} do
    user = Factory.user()

    conn
    |> post("/plaid/webhook", %{"item_id" => "bogus"})
    |> response(:not_found)

    member = Factory.bank_member(user, external_id: "webhook_test")

    data = %Banks.V1.SyncMemberRequest{member_id: member.id} |> Banks.V1.SyncMemberRequest.encode()

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
