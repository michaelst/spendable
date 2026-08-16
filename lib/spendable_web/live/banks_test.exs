defmodule SpendableWeb.Live.BanksTest do
  use SpendableWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias Spendable.Accounts
  alias Spendable.Banks
  alias Spendable.Banks.Schemas.BankAccount
  alias Spendable.Banks.Schemas.BankMember
  alias Spendable.Budgets
  alias Spendable.Repo
  alias Spendable.Scope

  setup %{conn: conn} do
    stub(TeslaMock, :call, fn
      %{method: :post, url: "https://sandbox.plaid.com/link/token/create"}, _opts ->
        TeslaHelper.response(body: %{"link_token" => "link-sandbox-token"})
    end)

    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{
        external_id: Ecto.UUID.generate(),
        provider: "google",
        bank_limit: 2
      })

    {:ok, bank_member} =
      Repo.insert(%BankMember{
        user_id: user.id,
        external_id: Ecto.UUID.generate(),
        name: "Tartan Bank",
        provider: "Plaid",
        plaid_token: "access-sandbox-token"
      })

    {:ok, bank_account} =
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
      |> Plug.Test.init_test_session(%{})
      |> put_session(:current_user_id, user.id)

    %{conn: conn, scope: Scope.for_user(user), bank_account: bank_account, member: bank_member}
  end

  test "lists the connected banks", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/banks")

    assert html =~ "Tartan Bank"
  end

  # An Apple Cash balance has no number to print, and dots with nothing after them say less than
  # the name on its own.
  test "reads an account with no number as just its name", %{conn: conn, member: member} do
    {:ok, view, _html} = live(conn, ~p"/banks")

    html = render_click(view, "select_bank_member", %{"id" => member.id})

    assert html =~ "Checking"
    refute html =~ "••••"
  end

  test "pushes a link token when opening Plaid Link", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/banks")

    render_click(view, "open_plaid_link", %{})

    assert_push_event(view, "open_plaid_link", %{"link_token" => "link-sandbox-token"})
  end

  # The button is offered whatever the limit, so the refusal has to be handled rather than crash.
  test "pushes nothing when the user is at their bank limit", %{conn: conn, scope: scope} do
    {:ok, _second} =
      Repo.insert(%BankMember{
        user_id: scope.user.id,
        external_id: Ecto.UUID.generate(),
        name: "Second Bank",
        provider: "Plaid",
        plaid_token: "access-sandbox-token"
      })

    {:ok, view, _html} = live(conn, ~p"/banks")

    render_click(view, "open_plaid_link", %{})

    refute_receive {_ref, {:push_event, "open_plaid_link", _payload}}, 50
  end

  # Plaid Link hands the public token back to the page once the user finishes connecting.
  test "connects the bank Plaid Link returns", %{conn: conn, scope: scope} do
    stub(TeslaMock, :call, fn
      %{method: :post, url: "https://sandbox.plaid.com/item/public_token/exchange"}, _opts ->
        TeslaHelper.response(body: %{"access_token" => "access-sandbox-token"})

      %{method: :post, url: "https://sandbox.plaid.com/item/get"}, _opts ->
        TeslaHelper.response(body: Spendable.TestData.Plaid.item())

      %{method: :post, url: "https://sandbox.plaid.com/institutions/get_by_id"}, _opts ->
        TeslaHelper.response(body: Spendable.TestData.Plaid.institution())
    end)

    {:ok, view, _html} = live(conn, ~p"/banks")

    render_click(view, "add_bank", %{"public_token" => "public-sandbox-token"})

    assert [%{name: "Tartan Bank"}, %{name: "Tartan Bank"}] = Banks.list_bank_members(scope)
  end

  test "toggles syncing for an account", %{conn: conn, member: member, bank_account: account} do
    {:ok, view, _html} = live(conn, ~p"/banks")

    render_click(view, "select_bank_member", %{"id" => member.id})
    render_click(view, "toggle_sync", %{"id" => account.id})

    assert %{sync: false} = Repo.reload(account)
  end

  test "queues a historical sync for a bank member", %{conn: conn, member: member} do
    {:ok, view, _html} = live(conn, ~p"/banks")

    render_click(view, "select_bank_member", %{"id" => member.id})
    render_click(view, "historical_sync", %{"id" => member.id})

    assert_enqueued(
      worker: Spendable.Banks.Jobs.SyncMember,
      args: %{
        bank_member_id: member.id,
        start_date: Date.to_iso8601(Date.shift(Date.utc_today(), month: -24))
      }
    )
  end

  test "assigns a budget to an account", %{
    conn: conn,
    scope: scope,
    member: member,
    bank_account: account
  } do
    {:ok, %{id: budget_id}} = Budgets.create_budget(scope, %{"name" => "Groceries"})

    {:ok, view, _html} = live(conn, ~p"/banks")

    render_click(view, "select_bank_member", %{"id" => member.id})

    render_change(view, "assign_budget", %{
      "bank_account" => %{"id" => account.id, "budget_id" => budget_id}
    })

    assert %{budget_id: ^budget_id} = Repo.reload(account)
  end

  test "filters the list by the search box", %{conn: conn, scope: scope} do
    {:ok, _other} =
      Repo.insert(%BankMember{
        user_id: scope.user.id,
        external_id: Ecto.UUID.generate(),
        name: "Other Bank",
        provider: "Plaid",
        plaid_token: "access-sandbox-token"
      })

    {:ok, view, _html} = live(conn, ~p"/banks")

    html = render_change(view, "search", %{"search" => "tartan"})

    assert html =~ "Tartan Bank"
    refute html =~ "Other Bank"
  end

  test "collapses a bank member that is selected twice", %{conn: conn, member: member} do
    {:ok, view, _html} = live(conn, ~p"/banks")

    render_click(view, "select_bank_member", %{"id" => member.id})
    html = render_click(view, "select_bank_member", %{"id" => member.id})

    refute html =~ "Checking"
  end
end
