defmodule Spendable.Web.Controllers.PlaidTest do
  use Spendable.Web.ConnCase, async: false

  import Mock

  alias Google.PubSub
  alias Spendable.TestUtils

  setup_with_mocks([
    {
      PubSub,
      [],
      publish: fn data, _topic ->
        send(self(), data)
        {:ok, %{status: 200}}
      end
    }
  ]) do
    :ok
  end

  test "webhook", %{conn: conn} do
    user = insert(:user)

    conn
    |> post("/plaid/webhook", %{"item_id" => "bogus"})
    |> response(:not_found)

    member = insert(:bank_member, user_id: user.id, external_id: "webhook_test")

    conn
    |> post("/plaid/webhook", %{"item_id" => "webhook_test"})
    |> response(:ok)

    TestUtils.assert_published(%SyncMemberRequest{member_id: member.id})

    conn
    |> post("/plaid/webhook", %{})
    |> response(:not_found)
  end
end
