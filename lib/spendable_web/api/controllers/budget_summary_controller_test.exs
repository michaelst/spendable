defmodule SpendableWeb.Api.BudgetSummaryControllerTest do
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

    {:ok, %{id: budget_id}} =
      Budgets.create_budget(scope, %{
        "name" => "Groceries",
        "type" => "envelope",
        "budgeted_amount" => "400.00"
      })

    {:ok, transaction} =
      Transactions.create_transaction(scope, %{
        "name" => "Market",
        "amount" => "-30.00",
        "date" => "2026-08-15",
        "reviewed" => false
      })

    {:ok, _allocated} =
      Transactions.update_transaction(scope, transaction, %{
        "budget_allocations" => %{"0" => %{"amount" => "-30.00", "budget_id" => budget_id}}
      })

    conn = put_req_header(conn, "authorization", "Bearer " <> api_token.token)

    %{conn: conn, budget_id: budget_id}
  end

  test "returns the month's numbers", %{conn: conn, budget_id: budget_id} do
    response = conn |> get(~p"/api/budgets/summary?month=2026-08-15") |> json_response(200)

    assert %{
             "month" => "2026-08-01",
             "allocated_total" => "400.00",
             "spent_total" => "30.00",
             "spent" => %{^budget_id => "30.00"}
           } = response

    assert_schema(response, "BudgetSummary", @api_spec)
  end

  test "defaults to the current month", %{conn: conn} do
    current_month = Date.to_iso8601(Date.beginning_of_month(Date.utc_today()))

    assert %{"month" => ^current_month, "current_month" => true} =
             conn |> get(~p"/api/budgets/summary") |> json_response(200)
  end

  test "credit card debt only applies to the current month", %{conn: conn} do
    assert %{"current_month" => false, "credit_card_balance" => "0.00"} =
             conn |> get(~p"/api/budgets/summary?month=2020-01-01") |> json_response(200)
  end

  test "carries the budgets the screen renders, Spendable first", %{conn: conn} do
    assert %{
             "budgets" => [
               %{"name" => "Spendable"},
               %{"name" => "Groceries", "budgeted_amount" => "400.00", "balance" => "-30.00"}
             ]
           } = conn |> get(~p"/api/budgets/summary?month=2026-08-01") |> json_response(200)
  end

  test "narrows the budgets to a search", %{conn: conn} do
    assert %{"budgets" => []} =
             conn |> get(~p"/api/budgets/summary?search=nothing") |> json_response(200)
  end

  test "offers the months the picker lists", %{conn: conn} do
    assert %{"spent_by_month" => months} =
             conn |> get(~p"/api/budgets/summary") |> json_response(200)

    assert %{"month" => "2026-08-01", "spent" => "-30.00"} = List.last(months)
  end

  test "rejects a month that is not a date", %{conn: conn} do
    response = conn |> get(~p"/api/budgets/summary?month=august") |> json_response(422)

    assert_schema(response, "Errors", @api_spec)
  end

  test "requires a token", %{conn: conn} do
    conn = delete_req_header(conn, "authorization")

    assert %{"errors" => [%{"code" => "unauthenticated"}]} =
             conn |> get(~p"/api/budgets/summary") |> json_response(401)
  end
end
