defmodule Spendable.Banks.Clients.PlaidTest do
  # Swaps the issuer, which is global, so this cannot share the scheduler with anything reading it.
  use Spendable.DataCase, async: false

  alias Spendable.Banks.Clients.Plaid
  alias Spendable.Support.TeslaHelper

  setup do
    issuer = Application.get_env(:spendable, :issuer)

    Application.put_env(:spendable, :issuer, "https://spendable.money")
    on_exit(fn -> Application.put_env(:spendable, :issuer, issuer) end)

    test_process = self()

    stub(TeslaMock, :call, fn %{method: :post, body: body}, _opts ->
      send(test_process, {:link_token, Jason.decode!(body)})

      TeslaHelper.response(body: %{"link_token" => "link-token"})
    end)

    :ok
  end

  # Most large US banks only offer OAuth, and OAuth cannot return to the app without this. The
  # value has to match one registered in the Plaid dashboard or the call is refused outright.
  test "a new connection asks the bank to return to the universal link" do
    {:ok, _response} = Plaid.create_link_token("usr_01")

    assert_received {:link_token, body}
    assert body["redirect_uri"] == "https://spendable.money/plaid-oauth"
    assert body["webhook"] == "https://spendable.money/plaid/webhook"
    assert body["products"] == ["transactions"]
  end

  # Repairing an item goes through the same OAuth page, so it needs the redirect just as much.
  test "reopening an existing connection asks for the same redirect" do
    {:ok, _response} = Plaid.create_link_token("usr_01", "access-token")

    assert_received {:link_token, body}
    assert body["redirect_uri"] == "https://spendable.money/plaid-oauth"
    assert body["access_token"] == "access-token"
    refute Map.has_key?(body, "products")
  end
end
