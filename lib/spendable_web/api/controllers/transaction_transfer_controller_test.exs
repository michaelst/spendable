defmodule SpendableWeb.Api.TransactionTransferControllerTest do
  use SpendableWeb.ConnCase, async: true

  import OpenApiSpex.TestAssertions

  alias Spendable.Accounts
  alias Spendable.Banks.Schemas.BankAccount
  alias Spendable.Banks.Schemas.BankMember
  alias Spendable.Banks.Schemas.BankTransaction
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

    {:ok, %{id: out_id} = out} =
      Transactions.create_transaction(scope, %{
        "name" => "To savings",
        "amount" => "-100.00",
        "date" => "2026-08-15"
      })

    {:ok, %{id: into_id} = into} =
      Transactions.create_transaction(scope, %{
        "name" => "From checking",
        "amount" => "100.00",
        "date" => "2026-08-15"
      })

    conn =
      conn
      |> put_req_header("authorization", "Bearer " <> api_token.token)
      |> put_req_header("content-type", "application/json")

    %{conn: conn, scope: scope, out: out, into: into, out_id: out_id, into_id: into_id}
  end

  test "links two sides of a transfer", %{
    conn: conn,
    out_id: out_id,
    into_id: into_id
  } do
    body = %{"transaction_ids" => [out_id, into_id]}

    response = conn |> post(~p"/api/transactions/transfer", body) |> json_response(200)

    assert [%{"id" => ^out_id, "transfer_id" => ^into_id} = one, %{"id" => ^into_id}] = response
    assert_schema(one, "Transaction", @api_spec)
  end

  # The list carries only the side that left, so that side has to answer for where it went.
  test "the side that left names the account the money arrived in", %{
    conn: conn,
    scope: scope,
    out: out,
    into: into
  } do
    {:ok, bank_member} =
      Repo.insert(%BankMember{
        user_id: scope.user.id,
        external_id: Ecto.UUID.generate(),
        name: "Tartan Bank",
        provider: "Plaid",
        plaid_token: "access-sandbox-token"
      })

    {:ok, bank_account} =
      Repo.insert(%BankAccount{
        user_id: scope.user.id,
        bank_member_id: bank_member.id,
        external_id: Ecto.UUID.generate(),
        name: "Savings",
        number: "9876",
        balance: Decimal.new("100.00"),
        sub_type: "savings",
        type: "depository"
      })

    {:ok, bank_transaction} =
      Repo.insert(%BankTransaction{
        user_id: scope.user.id,
        bank_account_id: bank_account.id,
        external_id: Ecto.UUID.generate(),
        amount: Decimal.new("100.00"),
        date: ~D[2026-08-15],
        name: "From checking",
        pending: false
      })

    {:ok, into} =
      Transactions.update_transaction(scope, into, %{"bank_transaction_id" => bank_transaction.id})

    body = %{"transaction_ids" => [out.id, into.id]}

    assert [%{"transfer_to" => %{"account_name" => "Savings"}}, %{"transfer_to" => nil}] =
             conn |> post(~p"/api/transactions/transfer", body) |> json_response(200)

    response = conn |> get(~p"/api/transactions/#{out.id}") |> json_response(200)

    assert %{"transfer_to" => %{"account_name" => "Savings", "account_number" => "9876"}} = response
    assert_schema(response, "Transaction", @api_spec)
  end

  test "a transfer's allocations are cleared onto Spendable", %{
    conn: conn,
    out: out,
    into: into
  } do
    body = %{"transaction_ids" => [out.id, into.id]}

    assert [%{"budget_allocations" => [%{"amount" => "-100.00"}]}, _into] =
             conn |> post(~p"/api/transactions/transfer", body) |> json_response(200)
  end

  test "both sides have to move in opposite directions", %{conn: conn, scope: scope, out: out} do
    {:ok, also_out} =
      Transactions.create_transaction(scope, %{
        "name" => "Also leaving",
        "amount" => "-50.00",
        "date" => "2026-08-15"
      })

    body = %{"transaction_ids" => [out.id, also_out.id]}

    assert %{"errors" => [%{"code" => "transfer_not_allowed"}]} =
             conn |> post(~p"/api/transactions/transfer", body) |> json_response(409)
  end

  test "a transaction already in a transfer cannot join another", %{
    conn: conn,
    scope: scope,
    out: out,
    into: into
  } do
    {:ok, _linked} = Transactions.mark_as_transfer(scope, out, into)

    {:ok, other} =
      Transactions.create_transaction(scope, %{
        "name" => "Another arrival",
        "amount" => "100.00",
        "date" => "2026-08-15"
      })

    body = %{"transaction_ids" => [out.id, other.id]}

    assert %{"errors" => [%{"code" => "already_transferred"}]} =
             conn |> post(~p"/api/transactions/transfer", body) |> json_response(409)
  end

  test "requires exactly two transactions", %{conn: conn, out: out} do
    body = %{"transaction_ids" => [out.id]}

    assert %{"errors" => [_invalid]} =
             conn |> post(~p"/api/transactions/transfer", body) |> json_response(422)
  end

  test "an unknown transaction is not found", %{conn: conn, out: out} do
    body = %{"transaction_ids" => [out.id, "txn_nope"]}

    assert %{"errors" => [%{"code" => "transaction_not_found"}]} =
             conn |> post(~p"/api/transactions/transfer", body) |> json_response(404)
  end

  test "unlinks a transfer", %{conn: conn, scope: scope, out: out, into: into} do
    {:ok, _linked} = Transactions.mark_as_transfer(scope, out, into)

    response = conn |> delete(~p"/api/transactions/#{out.id}/transfer") |> json_response(200)

    assert %{"transfer_id" => nil} = response
    assert_schema(response, "Transaction", @api_spec)

    assert %{"transfer_id" => nil} =
             conn |> get(~p"/api/transactions/#{into.id}") |> json_response(200)
  end

  test "unlinking something that is not a transfer is a conflict", %{conn: conn, out: out} do
    assert %{"errors" => [%{"code" => "not_a_transfer"}]} =
             conn |> delete(~p"/api/transactions/#{out.id}/transfer") |> json_response(409)
  end
end
