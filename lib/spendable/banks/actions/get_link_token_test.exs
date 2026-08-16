defmodule Spendable.Banks.Actions.GetLinkTokenTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Banks
  alias Spendable.Banks.Schemas.BankMember
  alias Spendable.Scope

  setup do
    stub(TeslaMock, :call, fn
      %{method: :post, url: "https://sandbox.plaid.com/link/token/create"}, _opts ->
        TeslaHelper.response(body: %{"link_token" => "link-sandbox-token"})
    end)

    :ok
  end

  test "returns a link token while the user has room for another bank" do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{
        external_id: Ecto.UUID.generate(),
        provider: "google",
        bank_limit: 1
      })

    assert {:ok, "link-sandbox-token"} = Banks.get_link_token(Scope.for_user(user))
  end

  # Checked before Plaid is called, so the user is not sent to pick a bank we would then refuse.
  test "refuses once the user is at their bank limit" do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    assert {:error, :bank_limit_reached} = Banks.get_link_token(Scope.for_user(user))
  end

  # The limit is about what a Plaid connection costs us, and FinanceKit reads from the device.
  test "a FinanceKit connection takes no slot" do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{
        external_id: Ecto.UUID.generate(),
        provider: "google",
        bank_limit: 1
      })

    scope = Scope.for_user(user)
    {:ok, _member} = Banks.upsert_finance_kit_member(scope)

    assert {:ok, "link-sandbox-token"} = Banks.get_link_token(scope)
  end

  # A connection with no Plaid token falls through to Plaid's new-item clause, which mints a token
  # that opens the wrong flow rather than reopening anything.
  test "refuses an update token for a connection Plaid does not hold" do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    scope = Scope.for_user(user)
    {:ok, member} = Banks.upsert_finance_kit_member(scope)

    assert {:error, :not_supported} = Banks.get_update_link_token(scope, member)
  end

  test "returns an update token for an existing connection" do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    {:ok, bank_member} =
      Repo.insert(%BankMember{
        user_id: user.id,
        external_id: Ecto.UUID.generate(),
        name: "Plaid",
        provider: "Plaid",
        plaid_token: "access-sandbox-token"
      })

    assert {:ok, "link-sandbox-token"} =
             Banks.get_update_link_token(Scope.for_user(user), bank_member)
  end

  test "refuses an update token for another user's connection" do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    {:ok, bank_member} =
      Repo.insert(%BankMember{
        user_id: other_user.id,
        external_id: Ecto.UUID.generate(),
        name: "Plaid",
        provider: "Plaid",
        plaid_token: "access-sandbox-token"
      })

    assert {:error, :not_authorized} =
             Banks.get_update_link_token(Scope.for_user(user), bank_member)
  end

  # The webhook follows the host the app is running on, so an item linked against a dev server
  # does not deliver its activity to production. A redirect URI has to be a universal link, which
  # http://localhost cannot be, so this environment sends none.
  test "the link token points its webhook at this host and asks for no redirect" do
    test_process = self()

    stub(TeslaMock, :call, fn %{method: :post, body: body}, _opts ->
      send(test_process, {:link_token, Jason.decode!(body)})

      TeslaHelper.response(body: %{"link_token" => "link-sandbox-token"})
    end)

    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{
        external_id: Ecto.UUID.generate(),
        provider: "google",
        bank_limit: 1
      })

    {:ok, _token} = Banks.get_link_token(Scope.for_user(user))

    assert_received {:link_token, body}
    assert body["webhook"] == "http://localhost:4002/plaid/webhook"
    refute Map.has_key?(body, "redirect_uri")
  end
end
