defmodule SpendableWeb.Live.BudgetsTest do
  use SpendableWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias Spendable.Accounts
  alias Spendable.Budgets
  alias Spendable.Scope
  alias Spendable.Transactions

  setup %{conn: conn} do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    conn =
      conn
      |> Plug.Test.init_test_session(%{})
      |> put_session(:current_user_id, user.id)

    %{conn: conn, scope: Scope.for_user(user)}
  end

  test "renders the budget list", %{conn: conn, scope: scope} do
    {:ok, _budget} = Budgets.create_budget(scope, %{"name" => "Groceries"})

    {:ok, _view, html} = live(conn, ~p"/budgets")

    assert html =~ "Groceries"
  end

  test "creates a budget", %{conn: conn, scope: scope} do
    {:ok, view, _html} = live(conn, ~p"/budgets")

    view |> element("#new-budget") |> render_click()

    view
    |> element(~s(form[phx-submit="submit"]))
    |> render_change(%{budget: %{"name" => "Groceries", "type" => "tracking"}})

    view
    |> element(~s(form[phx-submit="submit"]))
    |> render_submit(%{budget: %{"name" => "Groceries", "type" => "tracking"}})

    assert [%{name: "Groceries", type: :tracking}] = Budgets.list_budgets(scope)
  end

  test "keeps the form open and reports the error when the name is blank", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/budgets")

    view |> element("#new-budget") |> render_click()

    html =
      view
      |> element(~s(form[phx-submit="submit"]))
      |> render_submit(%{budget: %{"name" => ""}})

    assert html =~ "can&#39;t be blank"
  end

  test "edits a budget", %{conn: conn, scope: scope} do
    {:ok, budget} = Budgets.create_budget(scope, %{"name" => "Groceries"})

    {:ok, view, _html} = live(conn, ~p"/budgets")

    view |> element(~s(button[phx-value-id="#{budget.id}"])) |> render_click()

    view
    |> element(~s(form[phx-submit="submit"]))
    |> render_submit(%{budget: %{"name" => "Food", "type" => "envelope"}})

    assert [%{name: "Food"}] = Budgets.list_budgets(scope)
  end

  test "archives the budget being edited", %{conn: conn, scope: scope} do
    {:ok, budget} = Budgets.create_budget(scope, %{"name" => "Groceries"})

    {:ok, view, _html} = live(conn, ~p"/budgets")

    view |> element(~s(button[phx-value-id="#{budget.id}"])) |> render_click()
    view |> element("#archive") |> render_click()

    assert [] = Budgets.list_budgets(scope)
  end

  # A budget that was never saved has nothing to archive.
  test "offers no archive button on a new budget", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/budgets")

    html = view |> element("#new-budget") |> render_click()

    refute html =~ ~s(id="archive")
  end

  # Whatever a transaction leaves unallocated waits in Spendable, and the page leads with it.
  test "shows what is available to spend", %{conn: conn, scope: scope} do
    {:ok, _transaction} =
      Transactions.create_transaction(scope, %{
        "amount" => "-20.00",
        "date" => Date.utc_today(),
        "name" => "Groceries"
      })

    {:ok, _view, html} = live(conn, ~p"/budgets")

    assert html =~ "Spendable"
    assert html =~ "-$20.00"
  end

  test "reads an envelope as what is left of its budgeted amount", %{conn: conn, scope: scope} do
    {:ok, budget} =
      Budgets.create_budget(scope, %{
        "name" => "Groceries",
        "type" => "envelope",
        "budgeted_amount" => "650.00"
      })

    {:ok, _transaction} =
      Transactions.create_transaction(scope, %{
        "amount" => "-488.12",
        "date" => Date.utc_today(),
        "name" => "Market",
        "budget_allocations" => %{"0" => %{"amount" => "-488.12", "budget_id" => budget.id}}
      })

    {:ok, _view, html} = live(conn, ~p"/budgets")

    assert html =~ "LEFT"
    assert html =~ "$488.12 of $650.00 spent"
    # The month summary pairs what the envelopes hold against what went out of them.
    assert html =~ "Allocated"
    assert html =~ "$650.00"
    assert html =~ "$488.12"
  end

  # An envelope with nothing spent against it is not over budget, so its bar stays blue.
  test "marks an envelope red once it is overspent", %{conn: conn, scope: scope} do
    {:ok, budget} =
      Budgets.create_budget(scope, %{
        "name" => "Dining out",
        "type" => "envelope",
        "budgeted_amount" => "200.00"
      })

    {:ok, _transaction} =
      Transactions.create_transaction(scope, %{
        "amount" => "-264.50",
        "date" => Date.utc_today(),
        "name" => "Dinner",
        "budget_allocations" => %{"0" => %{"amount" => "-264.50", "budget_id" => budget.id}}
      })

    {:ok, _view, html} = live(conn, ~p"/budgets")

    assert html =~ "bg-red-500"
    refute html =~ "bg-blue-500"
  end

  test "reads a goal as what is still to go", %{conn: conn, scope: scope} do
    {:ok, _budget} =
      Budgets.create_budget(scope, %{
        "name" => "Emergency fund",
        "type" => "goal",
        "budgeted_amount" => "6000.00",
        "balance" => "4150.00"
      })

    {:ok, _view, html} = live(conn, ~p"/budgets")

    assert html =~ "TO GO"
    assert html =~ "$1,850.00"
    assert html =~ "$4,150.00 of $6,000.00 saved"
  end

  test "reads a goal with no amount as what it has saved", %{conn: conn, scope: scope} do
    {:ok, _budget} = Budgets.create_budget(scope, %{"name" => "Vacation", "type" => "goal"})

    {:ok, _view, html} = live(conn, ~p"/budgets")

    assert html =~ "SAVED"
    assert html =~ "No goal set"
  end

  test "reads a tracking budget as what was spent", %{conn: conn, scope: scope} do
    {:ok, _budget} = Budgets.create_budget(scope, %{"name" => "Shopping", "type" => "tracking"})

    {:ok, _view, html} = live(conn, ~p"/budgets")

    assert html =~ "SPENT"
    refute html =~ "No limit set"
  end

  # Dividing by the budgeted amount has to survive a budget set to nothing.
  test "renders an envelope budgeted at zero", %{conn: conn, scope: scope} do
    {:ok, _budget} =
      Budgets.create_budget(scope, %{
        "name" => "Gifts",
        "type" => "envelope",
        "budgeted_amount" => "0.00"
      })

    {:ok, _view, html} = live(conn, ~p"/budgets")

    assert html =~ "$0.00 of $0.00 spent"
    assert html =~ "width: 0.0%"
  end

  test "closes the details form", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/budgets")

    view |> element("#new-budget") |> render_click()
    html = render_click(view, "close", %{})

    refute html =~ ~s(phx-submit="submit")
  end

  # A past month is a record of what was spent, so there is no card debt to cover in it.
  test "shows a past month without the credit card debt", %{conn: conn, scope: scope} do
    {:ok, _budget} = Budgets.create_budget(scope, %{"name" => "Groceries"})
    last_month = Date.utc_today() |> Date.beginning_of_month() |> Date.add(-1)

    {:ok, view, _html} = live(conn, ~p"/budgets")

    html = render_click(view, "select_month", %{"month" => Date.to_iso8601(last_month)})

    assert html =~ "SPENT"
    refute html =~ "Credit Cards"
  end

  # Spendable is the figure the page opens with, so a card saying it again is the same word twice
  # about two different numbers.
  test "leaves the Spendable card off the current month", %{conn: conn, scope: scope} do
    {:ok, _transaction} =
      Transactions.create_transaction(scope, %{
        "amount" => "-20.00",
        "date" => Date.utc_today(),
        "name" => "Groceries"
      })

    {:ok, view, html} = live(conn, ~p"/budgets")

    assert html =~ "Spendable"
    refute has_element?(view, "h2", "Spendable")
  end

  # A past month has no Spendable figure above the list, so the budget is the only place left.
  test "keeps the Spendable card on a past month", %{conn: conn, scope: scope} do
    {:ok, _transaction} =
      Transactions.create_transaction(scope, %{
        "amount" => "-20.00",
        "date" => Date.utc_today(),
        "name" => "Groceries"
      })

    last_month = Date.utc_today() |> Date.beginning_of_month() |> Date.add(-1)

    {:ok, view, _html} = live(conn, ~p"/budgets")

    render_click(view, "select_month", %{"month" => Date.to_iso8601(last_month)})

    assert has_element?(view, "h2", "Spendable")
  end

  # Card debt reads the bank accounts and Spendable is whatever is left over. Neither is a card
  # anyone edits.
  test "offers no edit on the credit card total", %{conn: conn, scope: scope} do
    {:ok, _budget} = Budgets.create_budget(scope, %{"name" => "Groceries"})

    {:ok, view, html} = live(conn, ~p"/budgets")

    assert html =~ "BALANCE"
    assert has_element?(view, ~s(button[aria-label="Edit Groceries"]))
    refute has_element?(view, ~s(button[aria-label="Edit Credit Cards"]))
  end

  # Envelopes, then what is only tracked, then goals - the grouping does the work a heading would.
  test "orders the cards by type, with goals last", %{conn: conn, scope: scope} do
    {:ok, _goal} = Budgets.create_budget(scope, %{"name" => "Vacation", "type" => "goal"})
    {:ok, _tracking} = Budgets.create_budget(scope, %{"name" => "Amazon", "type" => "tracking"})
    {:ok, _envelope} = Budgets.create_budget(scope, %{"name" => "Rent", "type" => "envelope"})

    {:ok, _view, html} = live(conn, ~p"/budgets")

    assert [rent, amazon, vacation] =
             Enum.map(["Rent", "Amazon", "Vacation"], &(:binary.match(html, &1) |> elem(0)))

    assert rent < amazon
    assert amazon < vacation
  end

  test "filters the list by the search box", %{conn: conn, scope: scope} do
    {:ok, _groceries} = Budgets.create_budget(scope, %{"name" => "Groceries"})
    {:ok, _rent} = Budgets.create_budget(scope, %{"name" => "Rent"})

    {:ok, view, _html} = live(conn, ~p"/budgets")

    html = render_change(view, "search", %{"search" => "groc"})

    assert html =~ "Groceries"
    refute html =~ "Rent"
  end

  test "redirects when the session names no user" do
    conn = Plug.Test.init_test_session(build_conn(), %{})

    assert {:error, {:redirect, %{to: "/"}}} = live(conn, ~p"/budgets")
  end
end
