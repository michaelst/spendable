defmodule SpendableWeb.Api.SplitControllerTest do
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
    {:ok, %{id: budget_id}} = Budgets.create_budget(scope, %{"name" => "Rent"})

    conn =
      conn
      |> put_req_header("authorization", "Bearer " <> api_token.token)
      |> put_req_header("content-type", "application/json")

    %{conn: conn, scope: scope, budget_id: budget_id}
  end

  test "lists splits with their lines, so applying one needs no second call", %{
    conn: conn,
    scope: scope,
    budget_id: budget_id
  } do
    {:ok, _payday} =
      Budgets.create_split(scope, %{
        "name" => "Payday",
        "split_lines" => [%{"amount" => "-200.00", "budget_id" => budget_id}]
      })

    response = conn |> get(~p"/api/splits") |> json_response(200)

    assert [%{"name" => "Payday", "split_lines" => [%{"amount" => "-200.00"}]} = split] = response
    assert_schema(split, "Split", @api_spec)
  end

  test "narrows the list to a search", %{conn: conn, scope: scope} do
    {:ok, _payday} = Budgets.create_split(scope, %{"name" => "Payday"})
    {:ok, _bills} = Budgets.create_split(scope, %{"name" => "Bills"})

    assert [%{"name" => "Bills"}] = conn |> get(~p"/api/splits?search=Bil") |> json_response(200)
  end

  test "gets a split with its lines", %{conn: conn, scope: scope, budget_id: budget_id} do
    {:ok, %{id: id}} =
      Budgets.create_split(scope, %{
        "name" => "Payday",
        "split_lines" => [%{"amount" => "-200.00", "budget_id" => budget_id}]
      })

    response = conn |> get(~p"/api/splits/#{id}") |> json_response(200)

    assert %{
             "name" => "Payday",
             "split_lines" => [%{"amount" => "-200.00", "budget_id" => ^budget_id}]
           } = response

    assert_schema(response, "Split", @api_spec)
  end

  test "another user's split is not found", %{conn: conn} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    {:ok, split} = Budgets.create_split(Scope.for_user(other_user), %{"name" => "Theirs"})

    assert %{"errors" => [%{"code" => "split_not_found"}]} =
             conn |> get(~p"/api/splits/#{split.id}") |> json_response(404)
  end

  test "creates a split with lines", %{conn: conn, budget_id: budget_id} do
    body = %{
      "name" => "Payday",
      "split_lines" => [%{"amount" => "-200.00", "budget_id" => budget_id}]
    }

    response = conn |> post(~p"/api/splits", body) |> json_response(201)

    assert %{"name" => "Payday", "split_lines" => [%{"amount" => "-200.00"}]} = response
    assert_schema(response, "Split", @api_spec)
  end

  test "creates a split with no lines yet", %{conn: conn} do
    assert %{"name" => "Payday", "split_lines" => []} =
             conn |> post(~p"/api/splits", %{"name" => "Payday"}) |> json_response(201)
  end

  test "rejects a split without a name", %{conn: conn} do
    assert %{"errors" => [%{"source" => %{"pointer" => "/name"}}]} =
             conn |> post(~p"/api/splits", %{}) |> json_response(422)
  end

  test "rejects a line pointing at another user's budget", %{conn: conn} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    {:ok, budget} = Budgets.create_budget(Scope.for_user(other_user), %{"name" => "Theirs"})

    body = %{
      "name" => "Payday",
      "split_lines" => [%{"amount" => "-200.00", "budget_id" => budget.id}]
    }

    assert %{"errors" => [%{"source" => %{"pointer" => "/split_lines/0/budget_id"}}]} =
             conn |> post(~p"/api/splits", body) |> json_response(422)
  end

  test "a line sent with its id is updated in place", %{
    conn: conn,
    scope: scope,
    budget_id: budget_id
  } do
    {:ok, %{id: id, split_lines: [%{id: line_id}]}} =
      Budgets.create_split(scope, %{
        "name" => "Payday",
        "split_lines" => [%{"amount" => "-200.00", "budget_id" => budget_id}]
      })

    body = %{"split_lines" => [%{"id" => line_id, "amount" => "-250.00", "budget_id" => budget_id}]}

    assert %{"split_lines" => [%{"id" => ^line_id, "amount" => "-250.00"}]} =
             conn |> patch(~p"/api/splits/#{id}", body) |> json_response(200)
  end

  test "a line left out of the list is deleted", %{
    conn: conn,
    scope: scope,
    budget_id: budget_id
  } do
    {:ok, %{id: id}} =
      Budgets.create_split(scope, %{
        "name" => "Payday",
        "split_lines" => [
          %{"amount" => "-200.00", "budget_id" => budget_id},
          %{"amount" => "-50.00", "budget_id" => budget_id}
        ]
      })

    assert %{"split_lines" => []} =
             conn |> patch(~p"/api/splits/#{id}", %{"split_lines" => []}) |> json_response(200)
  end

  test "renames a split", %{conn: conn, scope: scope} do
    {:ok, %{id: id}} = Budgets.create_split(scope, %{"name" => "Payday"})

    response = conn |> patch(~p"/api/splits/#{id}", %{"name" => "Salary"}) |> json_response(200)

    assert %{"name" => "Salary"} = response
    assert_schema(response, "Split", @api_spec)
  end

  test "archives a split", %{conn: conn, scope: scope} do
    {:ok, %{id: id}} = Budgets.create_split(scope, %{"name" => "Payday"})

    assert %{"archived_at" => archived_at} =
             conn |> delete(~p"/api/splits/#{id}") |> json_response(200)

    assert {:ok, _archived_at, _offset} = DateTime.from_iso8601(archived_at)
    assert [] == conn |> get(~p"/api/splits") |> json_response(200)
  end

  test "archiving twice is a conflict", %{conn: conn, scope: scope} do
    {:ok, split} = Budgets.create_split(scope, %{"name" => "Payday"})
    {:ok, _archived} = Budgets.archive_split(scope, split)

    assert %{"errors" => [%{"code" => "already_archived"}]} =
             conn |> delete(~p"/api/splits/#{split.id}") |> json_response(409)
  end
end
