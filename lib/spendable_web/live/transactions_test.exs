defmodule SpendableWeb.Live.TransactionsTest do
  use SpendableWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias Spendable.Accounts
  alias Spendable.Budgets
  alias Spendable.Scope
  alias Spendable.Transactions

  setup %{conn: conn} do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    scope = Scope.for_user(user)
    {:ok, budget} = Budgets.create_budget(scope, %{"name" => "Groceries"})

    conn =
      conn
      |> Plug.Test.init_test_session(%{})
      |> put_session(:current_user_id, user.id)

    attrs = %{"amount" => "-5.00", "date" => "2026-08-15", "reviewed" => false}

    %{conn: conn, scope: scope, budget: budget, attrs: attrs}
  end

  test "renders the transaction list", %{conn: conn, scope: scope, attrs: attrs} do
    {:ok, _transaction} =
      Transactions.create_transaction(scope, Map.put(attrs, "name", "Coffee"))

    {:ok, _view, html} = live(conn, ~p"/transactions")

    assert html =~ "Coffee"
  end

  test "edits a transaction", %{conn: conn, scope: scope, attrs: attrs} do
    {:ok, transaction} =
      Transactions.create_transaction(scope, Map.put(attrs, "name", "Coffee"))

    {:ok, view, _html} = live(conn, ~p"/transactions")

    view |> element(~s(li[phx-value-id="#{transaction.id}"])) |> render_click()

    view
    |> element(~s(form[phx-submit="submit"]))
    |> render_submit(%{
      transaction: %{"name" => "Espresso", "amount" => "-5.00", "date" => "2026-08-15"}
    })

    assert [%{name: "Espresso"}] = Transactions.list_transactions(scope)
  end

  test "keeps the form open and reports the error when the name is blank", %{
    conn: conn,
    scope: scope,
    attrs: attrs
  } do
    {:ok, transaction} =
      Transactions.create_transaction(scope, Map.put(attrs, "name", "Coffee"))

    {:ok, view, _html} = live(conn, ~p"/transactions")

    view |> element(~s(li[phx-value-id="#{transaction.id}"])) |> render_click()

    html =
      view
      |> element(~s(form[phx-submit="submit"]))
      |> render_submit(%{transaction: %{"name" => "", "amount" => "-5.00", "date" => "2026-08-15"}})

    assert html =~ "can&#39;t be blank"
  end

  test "deletes the selected transactions", %{conn: conn, scope: scope, attrs: attrs} do
    {:ok, transaction} =
      Transactions.create_transaction(scope, Map.put(attrs, "name", "Coffee"))

    {:ok, view, _html} = live(conn, ~p"/transactions")

    render_click(view, "toggle_select_transaction", %{"id" => transaction.id, "value" => "on"})
    render_click(view, "delete", %{})

    assert [] = Transactions.list_transactions(scope)
  end

  test "keeps a transaction that is selected and then deselected", %{
    conn: conn,
    scope: scope,
    attrs: attrs
  } do
    {:ok, transaction} =
      Transactions.create_transaction(scope, Map.put(attrs, "name", "Coffee"))

    {:ok, view, _html} = live(conn, ~p"/transactions")

    render_click(view, "toggle_select_transaction", %{"id" => transaction.id, "value" => "on"})
    render_click(view, "toggle_select_transaction", %{"id" => transaction.id})
    render_click(view, "delete", %{})

    assert [%{name: "Coffee"}] = Transactions.list_transactions(scope)
  end

  test "applies a template's lines to the open transaction", %{
    conn: conn,
    scope: scope,
    budget: budget,
    attrs: attrs
  } do
    {:ok, template} =
      Budgets.create_template(scope, %{
        "name" => "Paycheck",
        "budget_allocation_template_lines" => %{
          "0" => %{"amount" => "-3.00", "budget_id" => budget.id}
        }
      })

    {:ok, transaction} =
      Transactions.create_transaction(scope, Map.put(attrs, "name", "Coffee"))

    {:ok, view, _html} = live(conn, ~p"/transactions")

    view |> element(~s(li[phx-value-id="#{transaction.id}"])) |> render_click()

    html = render_click(view, "apply_template", %{"template" => template.id})

    assert html =~ "-3.00"
  end

  test "hides reviewed transactions when the option is toggled off", %{
    conn: conn,
    scope: scope,
    attrs: attrs
  } do
    {:ok, _reviewed} =
      Transactions.create_transaction(
        scope,
        attrs |> Map.put("name", "Reviewed") |> Map.put("reviewed", true)
      )

    {:ok, view, _html} = live(conn, ~p"/transactions")

    assert render(view) =~ "Reviewed"

    refute render_click(view, "change_reviewed_option", %{}) =~ "Reviewed"
  end

  test "filters the list by the search box", %{conn: conn, scope: scope, attrs: attrs} do
    {:ok, _coffee} = Transactions.create_transaction(scope, Map.put(attrs, "name", "Coffee"))
    {:ok, _rent} = Transactions.create_transaction(scope, Map.put(attrs, "name", "Rent"))

    {:ok, view, _html} = live(conn, ~p"/transactions")

    html = render_change(view, "search", %{"search" => "coff"})

    assert html =~ "Coffee"
    refute html =~ "Rent"
  end
end
