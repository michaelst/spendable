defmodule SpendableWeb.Api.TransactionBulkControllerTest do
  use SpendableWeb.ConnCase, async: true

  import OpenApiSpex.TestAssertions

  alias Spendable.Accounts
  alias Spendable.Budgets
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

    {:ok, %{id: one_id}} =
      Transactions.create_transaction(scope, %{
        "name" => "Market",
        "amount" => "-30.00",
        "date" => "2026-08-15"
      })

    {:ok, %{id: two_id}} =
      Transactions.create_transaction(scope, %{
        "name" => "Cafe",
        "amount" => "-12.00",
        "date" => "2026-08-15"
      })

    conn =
      conn
      |> put_req_header("authorization", "Bearer " <> api_token.token)
      |> put_req_header("content-type", "application/json")

    %{conn: conn, scope: scope, budget_id: budget_id, one_id: one_id, two_id: two_id}
  end

  test "reviews several at once", %{conn: conn, one_id: one_id, two_id: two_id} do
    body = %{"transaction_ids" => [one_id, two_id], "reviewed" => true}

    response = conn |> patch(~p"/api/transactions/bulk", body) |> json_response(200)

    assert %{"transactions" => [%{"reviewed" => true}, %{"reviewed" => true}], "failed" => []} =
             response

    assert_schema(response, "BulkResult", @api_spec)
  end

  test "excludes several at once", %{conn: conn, one_id: one_id, two_id: two_id} do
    body = %{"transaction_ids" => [one_id, two_id], "excluded" => true}

    assert %{"transactions" => [%{"excluded" => true}, %{"excluded" => true}]} =
             conn |> patch(~p"/api/transactions/bulk", body) |> json_response(200)
  end

  test "spends each one's own amount from a budget", %{
    conn: conn,
    budget_id: budget_id,
    one_id: one_id,
    two_id: two_id
  } do
    body = %{"transaction_ids" => [one_id, two_id], "budget_id" => budget_id}

    assert %{
             "transactions" => [
               %{"budget_allocations" => [%{"budget_id" => ^budget_id, "amount" => "-30.00"}]},
               %{"budget_allocations" => [%{"budget_id" => ^budget_id, "amount" => "-12.00"}]}
             ]
           } = conn |> patch(~p"/api/transactions/bulk", body) |> json_response(200)
  end

  test "reports the ones that could not be changed", %{conn: conn, one_id: one_id} do
    body = %{"transaction_ids" => [one_id, "txn_gone"], "reviewed" => true}

    response = conn |> patch(~p"/api/transactions/bulk", body) |> json_response(200)

    assert %{
             "transactions" => [%{"id" => ^one_id}],
             "failed" => [%{"id" => "txn_gone", "code" => "transaction_not_found"}]
           } = response

    assert_schema(response, "BulkResult", @api_spec)
  end

  test "another user's transaction is reported as not found", %{conn: conn, one_id: one_id} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    {:ok, theirs} =
      Transactions.create_transaction(Scope.for_user(other_user), %{
        "name" => "Theirs",
        "amount" => "-1.00",
        "date" => "2026-08-15"
      })

    body = %{"transaction_ids" => [one_id, theirs.id], "reviewed" => true}

    assert %{"failed" => [%{"code" => "transaction_not_found"}]} =
             conn |> patch(~p"/api/transactions/bulk", body) |> json_response(200)
  end

  test "reports an invalid change without failing the rest", %{
    conn: conn,
    scope: scope,
    one_id: one_id,
    two_id: two_id
  } do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    {:ok, budget} = Budgets.create_budget(Scope.for_user(other_user), %{"name" => "Theirs"})
    {:ok, _reviewed} = Budgets.create_budget(scope, %{"name" => "Mine"})

    body = %{"transaction_ids" => [one_id, two_id], "budget_id" => budget.id}

    assert %{"transactions" => [], "failed" => [%{"code" => "invalid"}, %{"code" => "invalid"}]} =
             conn |> patch(~p"/api/transactions/bulk", body) |> json_response(200)
  end

  test "requires at least one transaction", %{conn: conn} do
    assert %{"errors" => [_invalid]} =
             conn |> patch(~p"/api/transactions/bulk", %{"transaction_ids" => []}) |> json_response(422)
  end

  test "deletes several at once", %{conn: conn, one_id: one_id, two_id: two_id} do
    body = %{"transaction_ids" => [one_id, two_id]}

    response = conn |> post(~p"/api/transactions/bulk/delete", body) |> json_response(200)

    assert %{"transactions" => [%{"id" => ^one_id}, %{"id" => ^two_id}], "failed" => []} = response
    assert [] == conn |> get(~p"/api/transactions") |> json_response(200)
  end

  test "reports a delete that found nothing", %{conn: conn} do
    body = %{"transaction_ids" => ["txn_gone"]}

    assert %{"failed" => [%{"id" => "txn_gone", "code" => "transaction_not_found"}]} =
             conn |> post(~p"/api/transactions/bulk/delete", body) |> json_response(200)
  end
end
