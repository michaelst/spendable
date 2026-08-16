defmodule SpendableWeb.Api.FallbackControllerTest do
  use SpendableWeb.ConnCase, async: true

  import OpenApiSpex.TestAssertions

  alias Spendable.Accounts
  alias Spendable.Budgets
  alias Spendable.Scope
  alias Spendable.Transactions
  alias SpendableWeb.Api.ApiSpec
  alias SpendableWeb.Api.FallbackController

  @api_spec ApiSpec.spec()

  setup do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    %{scope: Scope.for_user(user)}
  end

  test "a record owned by someone else is forbidden", %{conn: conn} do
    response =
      conn |> FallbackController.call({:error, :not_authorized}) |> json_response(403)

    assert %{"errors" => [%{"code" => "not_authorized", "detail" => "Not authorized"}]} = response
    assert_schema(response, "Errors", @api_spec)
  end

  test "an unknown record is not found", %{conn: conn} do
    response =
      conn |> FallbackController.call({:error, :budget_not_found}) |> json_response(404)

    assert %{"errors" => [%{"code" => "budget_not_found", "detail" => "Budget not found"}]} =
             response
  end

  test "a repeated state change is a conflict", %{conn: conn} do
    response =
      conn |> FallbackController.call({:error, :already_archived}) |> json_response(409)

    assert %{"errors" => [%{"code" => "already_archived"}]} = response
  end

  test "a changeset error points at the field that failed", %{conn: conn, scope: scope} do
    {:error, changeset} = Budgets.create_budget(scope, %{})

    response = conn |> FallbackController.call({:error, changeset}) |> json_response(422)

    assert %{
             "errors" => [
               %{"code" => "invalid", "detail" => "can't be blank", "source" => %{"pointer" => "/name"}}
             ]
           } = response

    assert_schema(response, "Errors", @api_spec)
  end

  test "a changeset error fills in the value the message interpolates", %{
    conn: conn,
    scope: scope
  } do
    {:error, changeset} =
      Accounts.create_api_token(scope, %{"device_name" => String.duplicate("a", 101)})

    response = conn |> FallbackController.call({:error, changeset}) |> json_response(422)

    assert %{"errors" => [%{"detail" => "should be at most 100 character(s)"}]} = response
  end

  test "a nested changeset error carries the index that failed", %{conn: conn, scope: scope} do
    {:ok, budget} = Budgets.create_budget(scope, %{"name" => "Groceries"})

    {:error, changeset} =
      Transactions.create_transaction(scope, %{
        "amount" => "-10.00",
        "date" => Date.utc_today(),
        "name" => "Coffee",
        "budget_allocations" => [%{"budget_id" => budget.id}]
      })

    response = conn |> FallbackController.call({:error, changeset}) |> json_response(422)

    assert %{"errors" => [%{"source" => %{"pointer" => "/budget_allocations/0/amount"}}]} =
             response
  end

  test "an error the API does not name crashes rather than answering", %{conn: conn} do
    assert_raise CondClauseError, fn ->
      FallbackController.call(conn, {:error, :something_unexpected})
    end
  end
end
