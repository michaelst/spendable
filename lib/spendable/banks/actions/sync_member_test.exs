defmodule Spendable.Banks.Actions.SyncMemberTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Banks
  alias Spendable.Banks.Schemas.BankMember
  alias Spendable.Scope
  alias Spendable.TestData
  alias Spendable.Transactions

  setup do
    stub(TeslaMock, :call, fn
      %{method: :post, url: "https://sandbox.plaid.com/item/get"}, _opts ->
        TeslaHelper.response(body: TestData.Plaid.item())

      %{method: :post, url: "https://sandbox.plaid.com/institutions/get_by_id"}, _opts ->
        TeslaHelper.response(body: TestData.Plaid.institution())

      %{method: :post, url: "https://sandbox.plaid.com/accounts/get"}, _opts ->
        TeslaHelper.response(body: TestData.Plaid.accounts())

      %{method: :post, url: "https://sandbox.plaid.com/transactions/get"}, _opts ->
        TeslaHelper.response(body: TestData.Plaid.account_transactions("zyBMmKBpeZcDVZgqEx3ACKveJjvwmBHomPbyP"))
    end)

    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    {:ok, bank_member} =
      Repo.insert(%BankMember{
        user_id: user.id,
        external_id: "jQ3ZbE3BWqUMeqNBgDK6fjdyErroNwu1EPKnL",
        name: "Plaid",
        provider: "Plaid",
        plaid_token: "access-sandbox-token"
      })

    %{scope: Scope.for_user(user), bank_member: bank_member}
  end

  test "names the connection from the institution", %{scope: scope, bank_member: bank_member} do
    :ok = Banks.sync_member(bank_member.id)

    assert [%{name: "Tartan Bank", status: "CONNECTED", institution_id: "ins_109511"}] =
             Banks.list_bank_members(scope)
  end

  test "brings the accounts across", %{scope: scope, bank_member: bank_member} do
    :ok = Banks.sync_member(bank_member.id)

    assert [%{bank_accounts: accounts}] = Banks.list_bank_members(scope)
    assert Enum.any?(accounts, &(&1.external_id == "zyBMmKBpeZcDVZgqEx3ACKveJjvwmBHomPbyP"))
  end

  # Every synced transaction becomes one the user can allocate, and until they do it waits in
  # Spendable.
  test "creates a transaction for each synced charge", %{scope: scope, bank_member: bank_member} do
    :ok = Banks.sync_member(bank_member.id)

    transactions = Transactions.list_transactions(scope, per_page: 100)

    refute Enum.empty?(transactions)
    assert Enum.all?(transactions, &(is_binary(&1.bank_transaction_id) and &1.reviewed == false))
  end

  # Plaid replays charges we already hold on every sync.
  test "re-syncing keeps one transaction per charge", %{scope: scope, bank_member: bank_member} do
    page = TestData.Plaid.account_transactions("zyBMmKBpeZcDVZgqEx3ACKveJjvwmBHomPbyP")
    [transaction | _rest] = page["transactions"]

    stub(TeslaMock, :call, fn
      %{method: :post, url: "https://sandbox.plaid.com/item/get"}, _opts ->
        TeslaHelper.response(body: TestData.Plaid.item())

      %{method: :post, url: "https://sandbox.plaid.com/institutions/get_by_id"}, _opts ->
        TeslaHelper.response(body: TestData.Plaid.institution())

      %{method: :post, url: "https://sandbox.plaid.com/accounts/get"}, _opts ->
        TeslaHelper.response(body: TestData.Plaid.accounts())

      %{method: :post, url: "https://sandbox.plaid.com/transactions/get"}, _opts ->
        TeslaHelper.response(body: %{page | "transactions" => [transaction], "total_transactions" => 1})
    end)

    :ok = Banks.sync_member(bank_member.id)
    :ok = Banks.sync_member(bank_member.id)

    assert [%{name: "Uber 072515 SF**POOL**"}] = Transactions.list_transactions(scope)
  end

  test "keeps reading pages until the last one", %{scope: scope, bank_member: bank_member} do
    page = TestData.Plaid.account_transactions("zyBMmKBpeZcDVZgqEx3ACKveJjvwmBHomPbyP")

    stub(TeslaMock, :call, fn
      %{method: :post, url: "https://sandbox.plaid.com/item/get"}, _opts ->
        TeslaHelper.response(body: TestData.Plaid.item())

      %{method: :post, url: "https://sandbox.plaid.com/institutions/get_by_id"}, _opts ->
        TeslaHelper.response(body: TestData.Plaid.institution())

      %{method: :post, url: "https://sandbox.plaid.com/accounts/get"}, _opts ->
        TeslaHelper.response(body: TestData.Plaid.accounts())

      %{method: :post, url: "https://sandbox.plaid.com/transactions/get"}, _opts ->
        TeslaHelper.response(body: %{page | "total_transactions" => 501})
    end)

    :ok = Banks.sync_member(bank_member.id)

    refute Enum.empty?(Transactions.list_transactions(scope, per_page: 100))
  end

  # The settled charge still arrives when we never saw the pending one it replaces.
  test "keeps a settled charge whose pending charge we never held", %{
    scope: scope,
    bank_member: bank_member
  } do
    page = TestData.Plaid.account_transactions("zyBMmKBpeZcDVZgqEx3ACKveJjvwmBHomPbyP")
    [transaction | _rest] = page["transactions"]

    stub(TeslaMock, :call, fn
      %{method: :post, url: "https://sandbox.plaid.com/item/get"}, _opts ->
        TeslaHelper.response(body: TestData.Plaid.item())

      %{method: :post, url: "https://sandbox.plaid.com/institutions/get_by_id"}, _opts ->
        TeslaHelper.response(body: TestData.Plaid.institution())

      %{method: :post, url: "https://sandbox.plaid.com/accounts/get"}, _opts ->
        TeslaHelper.response(body: TestData.Plaid.accounts())

      %{method: :post, url: "https://sandbox.plaid.com/transactions/get"}, _opts ->
        TeslaHelper.response(
          body: %{
            page
            | "transactions" => [Map.put(transaction, "pending_transaction_id", "never-synced")],
              "total_transactions" => 1
          }
        )
    end)

    :ok = Banks.sync_member(bank_member.id)

    assert [%{name: "Uber 072515 SF**POOL**"}] = Transactions.list_transactions(scope)
  end

  # A card balance is money owed, so it reads as negative against the accounts that hold money.
  test "records a credit card balance as debt", %{scope: scope, bank_member: bank_member} do
    accounts = TestData.Plaid.accounts()
    [account] = accounts["accounts"]

    stub(TeslaMock, :call, fn
      %{method: :post, url: "https://sandbox.plaid.com/item/get"}, _opts ->
        TeslaHelper.response(body: TestData.Plaid.item())

      %{method: :post, url: "https://sandbox.plaid.com/institutions/get_by_id"}, _opts ->
        TeslaHelper.response(body: TestData.Plaid.institution())

      %{method: :post, url: "https://sandbox.plaid.com/accounts/get"}, _opts ->
        TeslaHelper.response(body: %{accounts | "accounts" => [%{account | "type" => "credit"}]})

      %{method: :post, url: "https://sandbox.plaid.com/transactions/get"}, _opts ->
        TeslaHelper.response(body: TestData.Plaid.account_transactions("zyBMmKBpeZcDVZgqEx3ACKveJjvwmBHomPbyP"))
    end)

    :ok = Banks.sync_member(bank_member.id)

    assert [%{bank_accounts: [%{balance: balance}]}] = Banks.list_bank_members(scope)
    assert Decimal.eq?(balance, "-110")
  end

  # An expired login returns no accounts rather than an error, and there is nothing to sync until
  # the user reconnects.
  test "syncs no accounts while the login has expired", %{scope: scope, bank_member: bank_member} do
    stub(TeslaMock, :call, fn
      %{method: :post, url: "https://sandbox.plaid.com/item/get"}, _opts ->
        TeslaHelper.response(body: TestData.Plaid.item())

      %{method: :post, url: "https://sandbox.plaid.com/institutions/get_by_id"}, _opts ->
        TeslaHelper.response(body: TestData.Plaid.institution())

      %{method: :post, url: "https://sandbox.plaid.com/accounts/get"}, _opts ->
        TeslaHelper.response(body: %{"error_code" => "ITEM_LOGIN_REQUIRED"})
    end)

    :ok = Banks.sync_member(bank_member.id)

    assert [%{bank_accounts: []}] = Banks.list_bank_members(scope)
  end

  test "syncs no transactions while Plaid is still preparing them", %{
    scope: scope,
    bank_member: bank_member
  } do
    stub(TeslaMock, :call, fn
      %{method: :post, url: "https://sandbox.plaid.com/item/get"}, _opts ->
        TeslaHelper.response(body: TestData.Plaid.item())

      %{method: :post, url: "https://sandbox.plaid.com/institutions/get_by_id"}, _opts ->
        TeslaHelper.response(body: TestData.Plaid.institution())

      %{method: :post, url: "https://sandbox.plaid.com/accounts/get"}, _opts ->
        TeslaHelper.response(body: TestData.Plaid.accounts())

      %{method: :post, url: "https://sandbox.plaid.com/transactions/get"}, _opts ->
        TeslaHelper.response(body: %{"error_code" => "PRODUCT_NOT_READY"})
    end)

    :ok = Banks.sync_member(bank_member.id)

    assert [] = Transactions.list_transactions(scope)
  end

  test "errors when no member has that id" do
    assert {:error, :bank_member_not_found} =
             Banks.sync_member("bkm_01M036GTQ48JXS0A2AXFNV6H5P")
  end
end
