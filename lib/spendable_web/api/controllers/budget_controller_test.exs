defmodule SpendableWeb.Api.BudgetControllerTest do
  use SpendableWeb.ConnCase, async: true

  import OpenApiSpex.TestAssertions

  alias Spendable.Accounts
  alias Spendable.Budgets
  alias Spendable.Scope
  alias SpendableWeb.Api.ApiSpec

  @api_spec ApiSpec.spec()

  setup %{conn: conn} do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    scope = Scope.for_user(user)
    {:ok, api_token} = Accounts.create_api_token(scope, %{})

    conn =
      conn
      |> put_req_header("authorization", "Bearer " <> api_token.token)
      |> put_req_header("content-type", "application/json")

    %{conn: conn, scope: scope}
  end

  test "lists budgets with Spendable first", %{conn: conn, scope: scope} do
    {:ok, _groceries} = Budgets.create_budget(scope, %{"name" => "Groceries"})
    {:ok, _spendable} = Budgets.find_or_create_spendable_budget(scope)

    response = conn |> get(~p"/api/budgets") |> json_response(200)

    assert [%{"name" => "Spendable"} = spendable, %{"name" => "Groceries"}] = response
    assert_schema(spendable, "Budget", @api_spec)
  end

  test "narrows the list to a search", %{conn: conn, scope: scope} do
    {:ok, _groceries} = Budgets.create_budget(scope, %{"name" => "Groceries"})
    {:ok, _holiday} = Budgets.create_budget(scope, %{"name" => "Holiday"})

    assert [%{"name" => "Holiday"}] =
             conn |> get(~p"/api/budgets?search=Holi") |> json_response(200)
  end

  test "gets one budget", %{conn: conn, scope: scope} do
    {:ok, %{id: id}} = Budgets.create_budget(scope, %{"name" => "Groceries"})

    response = conn |> get(~p"/api/budgets/#{id}") |> json_response(200)

    assert %{"id" => ^id, "name" => "Groceries", "type" => "envelope"} = response
    assert_schema(response, "Budget", @api_spec)
  end

  test "another user's budget is not found", %{conn: conn} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    {:ok, budget} = Budgets.create_budget(Scope.for_user(other_user), %{"name" => "Theirs"})

    assert %{"errors" => [%{"code" => "budget_not_found"}]} =
             conn |> get(~p"/api/budgets/#{budget.id}") |> json_response(404)
  end

  test "creates a budget", %{conn: conn} do
    body = %{"name" => "Holiday", "type" => "goal", "budgeted_amount" => "500.00"}

    response = conn |> post(~p"/api/budgets", body) |> json_response(201)

    assert %{"name" => "Holiday", "type" => "goal", "budgeted_amount" => "500.00"} = response
    assert_schema(response, "Budget", @api_spec)
  end

  test "rejects a budget without a name", %{conn: conn} do
    response = conn |> post(~p"/api/budgets", %{"type" => "envelope"}) |> json_response(422)

    assert %{"errors" => [%{"source" => %{"pointer" => "/name"}}]} = response
  end

  test "rejects a type the app does not have", %{conn: conn} do
    body = %{"name" => "Holiday", "type" => "piggy_bank"}

    assert %{"errors" => [_invalid]} = conn |> post(~p"/api/budgets", body) |> json_response(422)
  end

  test "updates a budget", %{conn: conn, scope: scope} do
    {:ok, budget} = Budgets.create_budget(scope, %{"name" => "Groceries"})

    response =
      conn |> patch(~p"/api/budgets/#{budget.id}", %{"name" => "Food"}) |> json_response(200)

    assert %{"name" => "Food"} = response
    assert_schema(response, "Budget", @api_spec)
  end

  test "a requested balance comes back as the balance, not the adjustment", %{
    conn: conn,
    scope: scope
  } do
    {:ok, budget} = Budgets.create_budget(scope, %{"name" => "Groceries"})

    assert %{"balance" => "250.00"} =
             conn
             |> patch(~p"/api/budgets/#{budget.id}", %{"balance" => "250.00"})
             |> json_response(200)
  end

  test "omitting a field on update leaves it alone", %{conn: conn, scope: scope} do
    {:ok, budget} =
      Budgets.create_budget(scope, %{"name" => "Groceries", "budgeted_amount" => "400.00"})

    assert %{"name" => "Food", "budgeted_amount" => "400.00"} =
             conn
             |> patch(~p"/api/budgets/#{budget.id}", %{"name" => "Food"})
             |> json_response(200)
  end

  test "clearing a budgeted amount is distinct from omitting it", %{conn: conn, scope: scope} do
    {:ok, budget} =
      Budgets.create_budget(scope, %{"name" => "Groceries", "budgeted_amount" => "400.00"})

    assert %{"budgeted_amount" => nil} =
             conn
             |> patch(~p"/api/budgets/#{budget.id}", %{"budgeted_amount" => nil})
             |> json_response(200)
  end

  test "archives a budget", %{conn: conn, scope: scope} do
    {:ok, budget} = Budgets.create_budget(scope, %{"name" => "Groceries"})

    response = conn |> delete(~p"/api/budgets/#{budget.id}") |> json_response(200)

    assert %{"archived_at" => archived_at} = response
    assert {:ok, _archived_at, _offset} = DateTime.from_iso8601(archived_at)
    assert [] == conn |> get(~p"/api/budgets") |> json_response(200)
  end

  test "archiving twice is a conflict", %{conn: conn, scope: scope} do
    {:ok, budget} = Budgets.create_budget(scope, %{"name" => "Groceries"})
    {:ok, _archived} = Budgets.archive_budget(scope, budget)

    assert %{"errors" => [%{"code" => "already_archived"}]} =
             conn |> delete(~p"/api/budgets/#{budget.id}") |> json_response(409)
  end
end
