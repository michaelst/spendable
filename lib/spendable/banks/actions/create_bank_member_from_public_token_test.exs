defmodule Spendable.Banks.Actions.CreateBankMemberFromPublicTokenTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Banks
  alias Spendable.Banks.Jobs.SyncMember
  alias Spendable.Banks.Schemas.BankMember
  alias Spendable.Scope
  alias Spendable.TestData

  setup do
    stub(TeslaMock, :call, fn
      %{method: :post, url: "https://sandbox.plaid.com/item/public_token/exchange"}, _opts ->
        TeslaHelper.response(body: %{"access_token" => "access-sandbox-token"})

      %{method: :post, url: "https://sandbox.plaid.com/item/get"}, _opts ->
        TeslaHelper.response(body: TestData.Plaid.item())

      %{method: :post, url: "https://sandbox.plaid.com/institutions/get_by_id"}, _opts ->
        TeslaHelper.response(body: TestData.Plaid.institution())
    end)

    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{
        external_id: Ecto.UUID.generate(),
        provider: "google",
        bank_limit: 1
      })

    %{scope: Scope.for_user(user)}
  end

  test "exchanges the public token and keeps the access token", %{scope: scope} do
    assert {:ok,
            %BankMember{
              id: "bkm_" <> _uxid,
              name: "Tartan Bank",
              plaid_token: "access-sandbox-token"
            }} = Banks.create_bank_member_from_public_token(scope, "public-sandbox-token")
  end

  # The first sync pulls months of history, so the user is not left waiting on it.
  test "queues the first sync", %{scope: scope} do
    {:ok, bank_member} =
      Banks.create_bank_member_from_public_token(scope, "public-sandbox-token")

    assert_enqueued(worker: SyncMember, args: %{bank_member_id: bank_member.id})
  end

  # Reconnecting a bank the user already holds would be a second copy of the same connection.
  test "errors when the same connection is added twice" do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{
        external_id: Ecto.UUID.generate(),
        provider: "google",
        bank_limit: 2
      })

    scope = Scope.for_user(user)
    {:ok, _first} = Banks.create_bank_member_from_public_token(scope, "public-sandbox-token")

    assert {:error, changeset} =
             Banks.create_bank_member_from_public_token(scope, "public-sandbox-token")

    assert %{external_id: ["has already been taken"]} = errors_on(changeset)
  end

  # An external id is only unique within the provider that issued it, so it cannot be unique
  # across users - FinanceKit names its connection the same thing on every device.
  test "two users may hold a connection under the same external id", %{scope: scope} do
    {:ok, _mine} = Banks.create_bank_member_from_public_token(scope, "public-sandbox-token")

    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{
        external_id: Ecto.UUID.generate(),
        provider: "google",
        bank_limit: 1
      })

    assert {:ok, %BankMember{}} =
             Banks.create_bank_member_from_public_token(
               Scope.for_user(other_user),
               "public-sandbox-token"
             )
  end

  test "refuses once the user is at their bank limit", %{scope: scope} do
    {:ok, _first} = Banks.create_bank_member_from_public_token(scope, "public-sandbox-token")

    assert {:error, :bank_limit_reached} =
             Banks.create_bank_member_from_public_token(scope, "public-sandbox-token")
  end
end
