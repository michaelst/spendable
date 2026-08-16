defmodule Spendable.Banks.Actions.UpsertBankAccountTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Banks
  alias Spendable.Banks.Schemas.BankAccount
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

    scope = Scope.for_user(user)
    {:ok, bank_member} = Banks.create_bank_member_from_public_token(scope, "public-sandbox-token")

    attrs = %{
      balance: Decimal.new("100.00"),
      external_id: "acct-1",
      name: "Checking",
      number: "4321",
      sub_type: "checking",
      type: "depository"
    }

    %{scope: scope, bank_member: bank_member, attrs: attrs}
  end

  test "records an account the connection has not reported before", %{
    scope: scope,
    bank_member: bank_member,
    attrs: attrs
  } do
    assert {:ok, %BankAccount{id: "bka_" <> _uxid, name: "Checking", sync: true}} =
             Banks.upsert_bank_account(scope, bank_member, attrs)
  end

  # A second sync reports the same accounts, and the balance is the part that moved.
  test "updates the account already held rather than adding a copy", %{
    scope: scope,
    bank_member: bank_member,
    attrs: attrs
  } do
    {:ok, %{id: id}} = Banks.upsert_bank_account(scope, bank_member, attrs)

    assert {:ok, %BankAccount{id: ^id, balance: balance}} =
             Banks.upsert_bank_account(scope, bank_member, %{attrs | balance: Decimal.new("55.00")})

    assert Decimal.eq?(balance, "55.00")
    assert [%{bank_accounts: [_one]}] = Banks.list_bank_members(scope)
  end

  test "refuses a connection belonging to another user", %{bank_member: bank_member, attrs: attrs} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    assert {:error, :not_authorized} =
             Banks.upsert_bank_account(Scope.for_user(other_user), bank_member, attrs)
  end
end
