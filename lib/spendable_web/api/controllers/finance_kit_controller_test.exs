defmodule SpendableWeb.Api.FinanceKitControllerTest do
  use SpendableWeb.ConnCase, async: true

  import OpenApiSpex.TestAssertions

  alias Spendable.Accounts
  alias Spendable.Banks
  alias Spendable.Budgets
  alias Spendable.Scope
  alias Spendable.TestData
  alias Spendable.Transactions
  alias SpendableWeb.Api.ApiSpec

  @api_spec ApiSpec.spec()

  @card %{
    "external_id" => "apple-card",
    "name" => "Apple Card",
    "kind" => "credit_card",
    "balance" => "42.00",
    "credit_debit_indicator" => "debit"
  }

  @charge %{
    "account_external_id" => "apple-card",
    "external_id" => "txn-1",
    "amount" => "20.00",
    "credit_debit_indicator" => "debit",
    "date" => "2026-08-01",
    "name" => "Coffee",
    "pending" => true
  }

  setup %{conn: conn} do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    scope = Scope.for_user(user)
    {:ok, api_token} = Accounts.create_api_token(scope, %{})

    conn =
      conn
      |> put_req_header("authorization", "Bearer " <> api_token.token)
      |> put_req_header("content-type", "application/json")

    connection = conn |> post(~p"/api/banks/finance_kit") |> json_response(200)

    %{conn: conn, scope: scope, member_id: connection["id"]}
  end

  test "claims one connection however many times it is asked for", %{conn: conn} do
    response = conn |> post(~p"/api/banks/finance_kit") |> json_response(200)

    assert %{"name" => "Apple", "history_token" => nil, "bank_accounts" => []} = response
    assert_schema(response, "FinanceKitConnection", @api_spec)
    assert [%{"provider" => "FinanceKit"}] = conn |> get(~p"/api/banks") |> json_response(200)
  end

  # An unsigned amount plus an indicator, so the sign is the server's decision, not the device's.
  test "stores a debit as money out", %{conn: conn, scope: scope, member_id: id} do
    body = %{
      "history_token_before" => nil,
      "history_token_after" => "tok-1",
      "accounts" => [@card],
      "inserted" => [@charge]
    }

    response = conn |> post(~p"/api/banks/#{id}/finance_kit/changes", body) |> json_response(200)

    assert %{"applied" => 1, "history_token" => "tok-1"} = response
    assert_schema(response, "FinanceKitResult", @api_spec)

    assert [%{name: "Coffee", amount: amount}] = Transactions.list_transactions(scope)
    assert Decimal.eq?(amount, "-20.00")
  end

  # Apple Cash has real inflows, so the same rule has to run the other way too.
  test "stores a credit as money in", %{conn: conn, scope: scope, member_id: id} do
    cash = %{@card | "external_id" => "apple-cash", "kind" => "cash", "credit_debit_indicator" => "credit"}

    refund = %{
      @charge
      | "account_external_id" => "apple-cash",
        "credit_debit_indicator" => "credit",
        "name" => "Cash back"
    }

    body = %{
      "history_token_before" => nil,
      "history_token_after" => "tok-1",
      "accounts" => [cash],
      "inserted" => [refund]
    }

    assert %{"applied" => 1} =
             conn |> post(~p"/api/banks/#{id}/finance_kit/changes", body) |> json_response(200)

    assert [%{amount: amount}] = Transactions.list_transactions(scope)
    assert Decimal.eq?(amount, "20.00")

    assert [%{"bank_accounts" => [%{"balance" => "42.00", "sub_type" => "checking"}]}] =
             conn |> get(~p"/api/banks") |> json_response(200)
  end

  test "a card's balance is what is owed", %{conn: conn, member_id: id} do
    body = %{"history_token_before" => nil, "history_token_after" => "tok-1", "accounts" => [@card]}

    assert %{"applied" => 0} =
             conn |> post(~p"/api/banks/#{id}/finance_kit/changes", body) |> json_response(200)

    assert [%{"bank_accounts" => [%{"balance" => "-42.00", "sub_type" => "credit card"}]}] =
             conn |> get(~p"/api/banks") |> json_response(200)
  end

  # The device lost the response and sent the same batch again.
  test "replaying a batch changes nothing", %{conn: conn, scope: scope, member_id: id} do
    body = %{
      "history_token_before" => nil,
      "history_token_after" => "tok-1",
      "accounts" => [@card],
      "inserted" => [@charge]
    }

    assert %{"applied" => 1} =
             conn |> post(~p"/api/banks/#{id}/finance_kit/changes", body) |> json_response(200)

    assert %{"errors" => [%{"code" => "history_token_mismatch"}]} =
             conn |> post(~p"/api/banks/#{id}/finance_kit/changes", body) |> json_response(409)

    assert [_one] = Transactions.list_transactions(scope)
  end

  # Resent against the token the server holds, the same batch applies nothing new.
  test "a batch resent from the right place applies nothing twice", %{
    conn: conn,
    scope: scope,
    member_id: id
  } do
    first = %{
      "history_token_before" => nil,
      "history_token_after" => "tok-1",
      "accounts" => [@card],
      "inserted" => [@charge]
    }

    conn |> post(~p"/api/banks/#{id}/finance_kit/changes", first) |> json_response(200)

    again = %{first | "history_token_before" => "tok-1", "history_token_after" => "tok-2"}

    assert %{"applied" => 0, "history_token" => "tok-2"} =
             conn |> post(~p"/api/banks/#{id}/finance_kit/changes", again) |> json_response(200)

    assert [_one] = Transactions.list_transactions(scope)
  end

  # The whole reason a settling charge is updated rather than replaced.
  test "a charge that settles keeps what the user allocated", %{
    conn: conn,
    scope: scope,
    member_id: id
  } do
    first = %{
      "history_token_before" => nil,
      "history_token_after" => "tok-1",
      "accounts" => [@card],
      "inserted" => [@charge]
    }

    conn |> post(~p"/api/banks/#{id}/finance_kit/changes", first) |> json_response(200)

    {:ok, budget} = Budgets.create_budget(scope, %{"name" => "Coffee"})
    [transaction] = Transactions.list_transactions(scope)

    {:ok, _allocated} =
      Transactions.update_transaction(scope, transaction, %{
        "budget_allocations" => %{"0" => %{"amount" => "-5.00", "budget_id" => budget.id}}
      })

    settled = %{@charge | "amount" => "22.50", "pending" => false}

    second = %{
      "history_token_before" => "tok-1",
      "history_token_after" => "tok-2",
      "accounts" => [@card],
      "updated" => [settled]
    }

    assert %{"applied" => 1} =
             conn |> post(~p"/api/banks/#{id}/finance_kit/changes", second) |> json_response(200)

    {:ok, spendable} = Budgets.find_or_create_spendable_budget(scope)
    [restated] = Transactions.list_transactions(scope)
    by_budget = Map.new(restated.budget_allocations, &{&1.budget_id, &1.amount})

    assert Decimal.eq?(restated.amount, "-22.50")
    assert Decimal.eq?(by_budget[budget.id], "-5.00")
    assert Decimal.eq?(by_budget[spendable.id], "-17.50")
  end

  test "a reversed charge takes its transaction with it", %{
    conn: conn,
    scope: scope,
    member_id: id
  } do
    first = %{
      "history_token_before" => nil,
      "history_token_after" => "tok-1",
      "accounts" => [@card],
      "inserted" => [@charge]
    }

    conn |> post(~p"/api/banks/#{id}/finance_kit/changes", first) |> json_response(200)

    second = %{
      "history_token_before" => "tok-1",
      "history_token_after" => "tok-2",
      "accounts" => [@card],
      "deleted" => ["txn-1"]
    }

    assert %{"applied" => 1} =
             conn |> post(~p"/api/banks/#{id}/finance_kit/changes", second) |> json_response(200)

    assert [] = Transactions.list_transactions(scope)
  end

  # A charge whose insert we never held: the device is resuming past a response it never got.
  test "an update for a charge we never held inserts nothing", %{
    conn: conn,
    scope: scope,
    member_id: id
  } do
    body = %{
      "history_token_before" => nil,
      "history_token_after" => "tok-1",
      "accounts" => [@card],
      "updated" => [@charge],
      "deleted" => ["never-held"]
    }

    assert %{"applied" => 0} =
             conn |> post(~p"/api/banks/#{id}/finance_kit/changes", body) |> json_response(200)

    assert [] = Transactions.list_transactions(scope)
  end

  test "a Plaid connection cannot take FinanceKit changes", %{conn: conn} do
    stub(TeslaMock, :call, fn
      %{url: "https://sandbox.plaid.com/item/public_token/exchange"}, _opts ->
        TeslaHelper.response(body: %{"access_token" => "access-sandbox-token"})

      %{url: "https://sandbox.plaid.com/item/get"}, _opts ->
        TeslaHelper.response(body: TestData.Plaid.item())

      %{url: "https://sandbox.plaid.com/institutions/get_by_id"}, _opts ->
        TeslaHelper.response(body: TestData.Plaid.institution())
    end)

    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{
        external_id: Ecto.UUID.generate(),
        provider: "google",
        bank_limit: 1
      })

    scope = Scope.for_user(user)
    {:ok, api_token} = Accounts.create_api_token(scope, %{})
    {:ok, plaid} = Banks.create_bank_member_from_public_token(scope, "public-sandbox-token")

    body = %{"history_token_before" => nil, "history_token_after" => "tok-1", "accounts" => []}

    assert %{"errors" => [%{"code" => "not_supported"}]} =
             conn
             |> put_req_header("authorization", "Bearer " <> api_token.token)
             |> post(~p"/api/banks/#{plaid.id}/finance_kit/changes", body)
             |> json_response(409)
  end

  test "another user's connection is not found", %{conn: conn} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    {:ok, theirs} = Banks.upsert_finance_kit_member(Scope.for_user(other_user))

    body = %{"history_token_before" => nil, "history_token_after" => "tok-1", "accounts" => []}

    assert %{"errors" => [%{"code" => "bank_member_not_found"}]} =
             conn
             |> post(~p"/api/banks/#{theirs.id}/finance_kit/changes", body)
             |> json_response(404)
  end
end
