defmodule SpendableWeb.Api.BankAccountControllerTest do
  use SpendableWeb.ConnCase, async: true

  import OpenApiSpex.TestAssertions

  alias Spendable.Accounts
  alias Spendable.Banks.Schemas.BankAccount
  alias Spendable.Banks.Schemas.BankMember
  alias Spendable.Budgets
  alias Spendable.Repo
  alias Spendable.Scope
  alias SpendableWeb.Api.ApiSpec

  @api_spec ApiSpec.spec()

  setup %{conn: conn} do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    scope = Scope.for_user(user)
    {:ok, api_token} = Accounts.create_api_token(scope, %{})

    {:ok, bank_member} =
      Repo.insert(%BankMember{
        user_id: user.id,
        external_id: Ecto.UUID.generate(),
        name: "Tartan Bank",
        provider: "Plaid",
        plaid_token: "access-sandbox-token"
      })

    {:ok, %BankAccount{id: account_id}} =
      Repo.insert(%BankAccount{
        user_id: user.id,
        bank_member_id: bank_member.id,
        external_id: Ecto.UUID.generate(),
        name: "Checking",
        balance: Decimal.new("100.00"),
        sub_type: "checking",
        type: "depository"
      })

    conn =
      conn
      |> put_req_header("authorization", "Bearer " <> api_token.token)
      |> put_req_header("content-type", "application/json")

    %{conn: conn, scope: scope, account_id: account_id}
  end

  test "stops syncing an account", %{conn: conn, account_id: account_id} do
    response =
      conn |> patch(~p"/api/bank_accounts/#{account_id}", %{"sync" => false}) |> json_response(200)

    assert %{"sync" => false} = response
    assert_schema(response, "BankAccount", @api_spec)
  end

  test "assigns an account to a budget", %{conn: conn, scope: scope, account_id: account_id} do
    {:ok, %{id: budget_id}} = Budgets.create_budget(scope, %{"name" => "Rent"})

    assert %{"budget_id" => ^budget_id} =
             conn
             |> patch(~p"/api/bank_accounts/#{account_id}", %{"budget_id" => budget_id})
             |> json_response(200)
  end

  test "an assigned account becomes its budget's balance", %{
    conn: conn,
    scope: scope,
    account_id: account_id
  } do
    {:ok, %{id: budget_id}} = Budgets.create_budget(scope, %{"name" => "Rent"})

    conn |> patch(~p"/api/bank_accounts/#{account_id}", %{"budget_id" => budget_id})

    assert %{"balance" => "100.00"} =
             conn |> get(~p"/api/budgets/#{budget_id}") |> json_response(200)
  end

  test "unassigns an account", %{conn: conn, scope: scope, account_id: account_id} do
    {:ok, %{id: budget_id}} = Budgets.create_budget(scope, %{"name" => "Rent"})
    conn |> patch(~p"/api/bank_accounts/#{account_id}", %{"budget_id" => budget_id})

    assert %{"budget_id" => nil} =
             conn
             |> patch(~p"/api/bank_accounts/#{account_id}", %{"budget_id" => nil})
             |> json_response(200)
  end

  test "rejects another user's budget", %{conn: conn, account_id: account_id} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    {:ok, budget} = Budgets.create_budget(Scope.for_user(other_user), %{"name" => "Theirs"})

    assert %{"errors" => [%{"source" => %{"pointer" => "/budget_id"}}]} =
             conn
             |> patch(~p"/api/bank_accounts/#{account_id}", %{"budget_id" => budget.id})
             |> json_response(422)
  end

  test "another user's account is not found", %{conn: conn} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    {:ok, theirs_member} =
      Repo.insert(%BankMember{
        user_id: other_user.id,
        external_id: Ecto.UUID.generate(),
        name: "Theirs",
        provider: "Plaid",
        plaid_token: "access-sandbox-token"
      })

    {:ok, theirs} =
      Repo.insert(%BankAccount{
        user_id: other_user.id,
        bank_member_id: theirs_member.id,
        external_id: Ecto.UUID.generate(),
        name: "Theirs",
        balance: Decimal.new("1.00"),
        sub_type: "checking",
        type: "depository"
      })

    assert %{"errors" => [%{"code" => "bank_account_not_found"}]} =
             conn
             |> patch(~p"/api/bank_accounts/#{theirs.id}", %{"sync" => false})
             |> json_response(404)
  end
end
