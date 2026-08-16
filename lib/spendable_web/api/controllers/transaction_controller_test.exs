defmodule SpendableWeb.Api.TransactionControllerTest do
  use SpendableWeb.ConnCase, async: true

  import OpenApiSpex.TestAssertions

  alias Spendable.Accounts
  alias Spendable.Banks.Schemas.BankAccount
  alias Spendable.Banks.Schemas.BankMember
  alias Spendable.Banks.Schemas.BankTransaction
  alias Spendable.Budgets
  alias Spendable.Repo
  alias Spendable.Scope
  alias Spendable.Transactions
  alias SpendableWeb.Api.ApiSpec

  @api_spec ApiSpec.spec()

  setup %{conn: conn} do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    scope = Scope.for_user(user)
    {:ok, api_token} = Accounts.create_api_token(scope, %{})
    {:ok, %{id: budget_id}} = Budgets.create_budget(scope, %{"name" => "Groceries"})

    conn =
      conn
      |> put_req_header("authorization", "Bearer " <> api_token.token)
      |> put_req_header("content-type", "application/json")

    %{conn: conn, scope: scope, budget_id: budget_id}
  end

  test "lists unreviewed transactions newest first", %{conn: conn, scope: scope} do
    {:ok, _older} =
      Transactions.create_transaction(scope, %{
        "name" => "Older",
        "amount" => "-10.00",
        "date" => "2026-08-01"
      })

    {:ok, _newer} =
      Transactions.create_transaction(scope, %{
        "name" => "Newer",
        "amount" => "-20.00",
        "date" => "2026-08-15"
      })

    response = conn |> get(~p"/api/transactions") |> json_response(200)

    assert [%{"name" => "Newer"} = newest, %{"name" => "Older"}] = response
    assert_schema(newest, "Transaction", @api_spec)
  end

  test "hides reviewed transactions unless asked for", %{conn: conn, scope: scope} do
    {:ok, _reviewed} =
      Transactions.create_transaction(scope, %{
        "name" => "Done",
        "amount" => "-10.00",
        "date" => "2026-08-01",
        "reviewed" => true
      })

    assert [] == conn |> get(~p"/api/transactions") |> json_response(200)

    assert [%{"name" => "Done"}] =
             conn |> get(~p"/api/transactions?show_reviewed=true") |> json_response(200)
  end

  test "hides excluded transactions unless asked for", %{conn: conn, scope: scope} do
    {:ok, transaction} =
      Transactions.create_transaction(scope, %{
        "name" => "Refund",
        "amount" => "-10.00",
        "date" => "2026-08-01"
      })

    {:ok, _excluded} = Transactions.update_transaction(scope, transaction, %{"excluded" => true})

    assert [] == conn |> get(~p"/api/transactions") |> json_response(200)

    assert [%{"name" => "Refund"}] =
             conn |> get(~p"/api/transactions?show_excluded=true") |> json_response(200)
  end

  test "searches name and note", %{conn: conn, scope: scope} do
    {:ok, transaction} =
      Transactions.create_transaction(scope, %{
        "name" => "Market",
        "amount" => "-10.00",
        "date" => "2026-08-01"
      })

    {:ok, _noted} = Transactions.update_transaction(scope, transaction, %{"note" => "birthday"})

    assert [%{"name" => "Market"}] =
             conn |> get(~p"/api/transactions?search=birth") |> json_response(200)
  end

  test "pages", %{conn: conn, scope: scope} do
    for day <- 1..3 do
      {:ok, _transaction} =
        Transactions.create_transaction(scope, %{
          "name" => "Day #{day}",
          "amount" => "-10.00",
          "date" => "2026-08-0#{day}"
        })
    end

    assert [%{"name" => "Day 3"}] =
             conn |> get(~p"/api/transactions?per_page=1&page=1") |> json_response(200)

    assert [%{"name" => "Day 2"}] =
             conn |> get(~p"/api/transactions?per_page=1&page=2") |> json_response(200)
  end

  test "rejects a page size past the ceiling", %{conn: conn} do
    response = conn |> get(~p"/api/transactions?per_page=5000") |> json_response(422)

    assert_schema(response, "Errors", @api_spec)
  end

  test "creates a transaction and parks the remainder on Spendable", %{conn: conn} do
    body = %{"name" => "Market", "amount" => "-30.00", "date" => "2026-08-15"}

    response = conn |> post(~p"/api/transactions", body) |> json_response(201)

    assert %{"name" => "Market", "budget_allocations" => [%{"amount" => "-30.00"}]} = response
    assert_schema(response, "Transaction", @api_spec)
  end

  test "allocations sent are what the server settles on", %{conn: conn, budget_id: budget_id} do
    body = %{
      "name" => "Market",
      "amount" => "-30.00",
      "date" => "2026-08-15",
      "budget_allocations" => [%{"amount" => "-20.00", "budget_id" => budget_id}]
    }

    response = conn |> post(~p"/api/transactions", body) |> json_response(201)

    assert %{"budget_allocations" => allocations} = response
    assert length(allocations) == 2
    assert Enum.any?(allocations, &(&1["budget_id"] == budget_id and &1["amount"] == "-20.00"))
  end

  test "rejects a transaction without an amount", %{conn: conn} do
    body = %{"name" => "Market", "date" => "2026-08-15"}

    assert %{"errors" => [%{"source" => %{"pointer" => "/amount"}}]} =
             conn |> post(~p"/api/transactions", body) |> json_response(422)
  end

  test "gets one transaction", %{conn: conn, scope: scope} do
    {:ok, %{id: id}} =
      Transactions.create_transaction(scope, %{
        "name" => "Market",
        "amount" => "-30.00",
        "date" => "2026-08-15"
      })

    response = conn |> get(~p"/api/transactions/#{id}") |> json_response(200)

    assert %{"id" => ^id, "name" => "Market", "source" => nil} = response
    assert_schema(response, "Transaction", @api_spec)
  end

  test "a synced transaction carries the account it came from", %{conn: conn, scope: scope} do
    {:ok, bank_member} =
      Repo.insert(%BankMember{
        user_id: scope.user.id,
        external_id: Ecto.UUID.generate(),
        name: "Tartan Bank",
        provider: "Plaid",
        plaid_token: "access-sandbox-token",
        logo: Base.encode64(<<137, 80, 78, 71>>)
      })

    {:ok, bank_account} =
      Repo.insert(%BankAccount{
        user_id: scope.user.id,
        bank_member_id: bank_member.id,
        external_id: Ecto.UUID.generate(),
        name: "Checking",
        number: "1234",
        balance: Decimal.new("100.00"),
        sub_type: "checking",
        type: "depository"
      })

    {:ok, bank_transaction} =
      Repo.insert(%BankTransaction{
        user_id: scope.user.id,
        bank_account_id: bank_account.id,
        external_id: Ecto.UUID.generate(),
        amount: Decimal.new("-5.00"),
        date: ~D[2026-08-15],
        name: "Coffee",
        pending: true
      })

    {:ok, %{id: id}} =
      Transactions.create_transaction(scope, %{
        "name" => "Coffee",
        "amount" => "-5.00",
        "date" => "2026-08-15",
        "bank_transaction_id" => bank_transaction.id
      })

    response = conn |> get(~p"/api/transactions/#{id}") |> json_response(200)

    assert %{
             "source" => %{
               "account_name" => "Checking",
               "account_number" => "1234",
               "member_name" => "Tartan Bank",
               "member_has_logo" => true,
               "member_provider" => "Plaid",
               "pending" => true
             }
           } = response

    assert_schema(response, "Transaction", @api_spec)
  end

  test "another user's transaction is not found", %{conn: conn} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    {:ok, transaction} =
      Transactions.create_transaction(Scope.for_user(other_user), %{
        "name" => "Theirs",
        "amount" => "-30.00",
        "date" => "2026-08-15"
      })

    assert %{"errors" => [%{"code" => "transaction_not_found"}]} =
             conn |> get(~p"/api/transactions/#{transaction.id}") |> json_response(404)
  end

  test "reviewing a transaction", %{conn: conn, scope: scope} do
    {:ok, %{id: id}} =
      Transactions.create_transaction(scope, %{
        "name" => "Market",
        "amount" => "-30.00",
        "date" => "2026-08-15"
      })

    response =
      conn |> patch(~p"/api/transactions/#{id}", %{"reviewed" => true}) |> json_response(200)

    assert %{"reviewed" => true} = response
    assert_schema(response, "Transaction", @api_spec)
  end

  test "reallocating rebuilds the remainder rather than trusting what was sent", %{
    conn: conn,
    scope: scope,
    budget_id: budget_id
  } do
    {:ok, %{id: id}} =
      Transactions.create_transaction(scope, %{
        "name" => "Market",
        "amount" => "-30.00",
        "date" => "2026-08-15"
      })

    body = %{"budget_allocations" => [%{"amount" => "-30.00", "budget_id" => budget_id}]}

    assert %{"budget_allocations" => [%{"budget_id" => ^budget_id, "amount" => "-30.00"}]} =
             conn |> patch(~p"/api/transactions/#{id}", body) |> json_response(200)
  end

  test "rejects an allocation pointing at another user's budget", %{conn: conn, scope: scope} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    {:ok, budget} = Budgets.create_budget(Scope.for_user(other_user), %{"name" => "Theirs"})

    {:ok, %{id: id}} =
      Transactions.create_transaction(scope, %{
        "name" => "Market",
        "amount" => "-30.00",
        "date" => "2026-08-15"
      })

    body = %{"budget_allocations" => [%{"amount" => "-30.00", "budget_id" => budget.id}]}

    assert %{"errors" => [%{"detail" => "does not exist", "source" => %{"pointer" => pointer}}]} =
             conn |> patch(~p"/api/transactions/#{id}", body) |> json_response(422)

    assert String.ends_with?(pointer, "/budget_id")
  end

  test "deletes a transaction", %{conn: conn, scope: scope} do
    {:ok, %{id: id}} =
      Transactions.create_transaction(scope, %{
        "name" => "Market",
        "amount" => "-30.00",
        "date" => "2026-08-15"
      })

    assert conn |> delete(~p"/api/transactions/#{id}") |> response(204)

    assert %{"errors" => [%{"code" => "transaction_not_found"}]} =
             conn |> get(~p"/api/transactions/#{id}") |> json_response(404)
  end
end
