defmodule SpendableWeb.Api.BankMemberControllerTest do
  use SpendableWeb.ConnCase, async: true

  import OpenApiSpex.TestAssertions

  alias Spendable.Accounts
  alias Spendable.Banks.Schemas.BankAccount
  alias Spendable.Banks.Schemas.BankMember
  alias Spendable.Repo
  alias Spendable.Scope
  alias Spendable.TestData
  alias SpendableWeb.Api.ApiSpec

  @api_spec ApiSpec.spec()

  setup %{conn: conn} do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{
        external_id: Ecto.UUID.generate(),
        provider: "google",
        bank_limit: 1
      })

    scope = Scope.for_user(user)
    {:ok, api_token} = Accounts.create_api_token(scope, %{})

    conn =
      conn
      |> put_req_header("authorization", "Bearer " <> api_token.token)
      |> put_req_header("content-type", "application/json")

    %{conn: conn, scope: scope, user: user}
  end

  test "lists connections with their accounts", %{conn: conn, user: user} do
    {:ok, bank_member} =
      Repo.insert(%BankMember{
        user_id: user.id,
        external_id: Ecto.UUID.generate(),
        name: "Tartan Bank",
        provider: "Plaid",
        status: "CONNECTED",
        plaid_token: "access-sandbox-token",
        logo: Base.encode64(<<137, 80, 78, 71>>)
      })

    {:ok, _account} =
      Repo.insert(%BankAccount{
        user_id: user.id,
        bank_member_id: bank_member.id,
        external_id: Ecto.UUID.generate(),
        name: "Checking",
        number: "1234",
        balance: Decimal.new("100.00"),
        sub_type: "checking",
        type: "depository"
      })

    response = conn |> get(~p"/api/banks") |> json_response(200)

    assert [
             %{
               "name" => "Tartan Bank",
               "status" => "CONNECTED",
               "has_logo" => true,
               "bank_accounts" => [%{"name" => "Checking", "balance" => "100.00", "sync" => true}]
             } = member
           ] = response

    assert_schema(member, "BankMember", @api_spec)
  end

  test "narrows the list to a search", %{conn: conn, user: user} do
    {:ok, _tartan} =
      Repo.insert(%BankMember{
        user_id: user.id,
        external_id: Ecto.UUID.generate(),
        name: "Tartan Bank",
        provider: "Plaid",
        plaid_token: "access-sandbox-token"
      })

    assert [] == conn |> get(~p"/api/banks?search=nothing") |> json_response(200)
  end

  test "hands out a link token", %{conn: conn} do
    stub(TeslaMock, :call, fn %{url: "https://sandbox.plaid.com/link/token/create"}, _opts ->
      TeslaHelper.response(body: %{"link_token" => "link-sandbox-token"})
    end)

    response = conn |> post(~p"/api/banks/link_token") |> json_response(200)

    assert %{"link_token" => "link-sandbox-token"} = response
    assert_schema(response, "LinkToken", @api_spec)
  end

  test "refuses a link token once the user is at their bank limit", %{conn: conn, user: user} do
    {:ok, _at_limit} =
      Repo.insert(%BankMember{
        user_id: user.id,
        external_id: Ecto.UUID.generate(),
        name: "Tartan Bank",
        provider: "Plaid",
        plaid_token: "access-sandbox-token"
      })

    assert %{"errors" => [%{"code" => "bank_limit_reached"}]} =
             conn |> post(~p"/api/banks/link_token") |> json_response(409)
  end

  test "hands out an update token for reconnecting", %{conn: conn, user: user} do
    stub(TeslaMock, :call, fn %{url: "https://sandbox.plaid.com/link/token/create"}, _opts ->
      TeslaHelper.response(body: %{"link_token" => "link-sandbox-update"})
    end)

    {:ok, bank_member} =
      Repo.insert(%BankMember{
        user_id: user.id,
        external_id: Ecto.UUID.generate(),
        name: "Tartan Bank",
        provider: "Plaid",
        status: "ITEM_LOGIN_REQUIRED",
        plaid_token: "access-sandbox-token"
      })

    assert %{"link_token" => "link-sandbox-update"} =
             conn |> post(~p"/api/banks/#{bank_member.id}/link_token") |> json_response(200)
  end

  test "connects a bank from a public token", %{conn: conn} do
    stub(TeslaMock, :call, fn
      %{url: "https://sandbox.plaid.com/item/public_token/exchange"}, _opts ->
        TeslaHelper.response(body: %{"access_token" => "access-sandbox-token"})

      %{url: "https://sandbox.plaid.com/item/get"}, _opts ->
        TeslaHelper.response(body: TestData.Plaid.item())

      %{url: "https://sandbox.plaid.com/institutions/get_by_id"}, _opts ->
        TeslaHelper.response(body: TestData.Plaid.institution())
    end)

    response =
      conn
      |> post(~p"/api/banks", %{"public_token" => "public-sandbox-token"})
      |> json_response(201)

    assert %{"bank_accounts" => []} = response
    assert_schema(response, "BankMember", @api_spec)
  end

  test "refuses to connect once the user is at their bank limit", %{conn: conn, user: user} do
    {:ok, _at_limit} =
      Repo.insert(%BankMember{
        user_id: user.id,
        external_id: Ecto.UUID.generate(),
        name: "Tartan Bank",
        provider: "Plaid",
        plaid_token: "access-sandbox-token"
      })

    assert %{"errors" => [%{"code" => "bank_limit_reached"}]} =
             conn
             |> post(~p"/api/banks", %{"public_token" => "public-sandbox-token"})
             |> json_response(409)
  end

  test "queues a historical sync", %{conn: conn, user: user} do
    {:ok, bank_member} =
      Repo.insert(%BankMember{
        user_id: user.id,
        external_id: Ecto.UUID.generate(),
        name: "Tartan Bank",
        provider: "Plaid",
        plaid_token: "access-sandbox-token"
      })

    assert conn |> post(~p"/api/banks/#{bank_member.id}/sync") |> response(202)

    assert_enqueued(
      worker: Spendable.Banks.Jobs.SyncMember,
      args: %{bank_member_id: bank_member.id}
    )
  end

  test "another user's connection is not found", %{conn: conn} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    {:ok, theirs} =
      Repo.insert(%BankMember{
        user_id: other_user.id,
        external_id: Ecto.UUID.generate(),
        name: "Theirs",
        provider: "Plaid",
        plaid_token: "access-sandbox-token"
      })

    assert %{"errors" => [%{"code" => "bank_member_not_found"}]} =
             conn |> post(~p"/api/banks/#{theirs.id}/sync") |> json_response(404)
  end
end
