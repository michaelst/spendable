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

  # Splitting posts every line's own amount, so the transaction's amount no longer stands in.
  test "splits a transaction across two budgets", %{
    conn: conn,
    scope: scope,
    budget: budget,
    attrs: attrs
  } do
    {:ok, other} = Budgets.create_budget(scope, %{"name" => "Rent"})

    {:ok, transaction} =
      Transactions.create_transaction(scope, Map.put(attrs, "name", "Coffee"))

    {:ok, view, _html} = live(conn, ~p"/transactions")

    view |> element(~s(li[phx-value-id="#{transaction.id}"])) |> render_click()

    params = %{
      "name" => "Coffee",
      "amount" => "-5.00",
      "date" => "2026-08-15",
      "allocations_sort" => ["0", "1"],
      "budget_allocations" => %{
        "0" => %{"amount" => "-3.00", "budget_id" => budget.id},
        "1" => %{"amount" => "-2.00", "budget_id" => other.id}
      }
    }

    view |> element(~s(form[phx-submit="submit"])) |> render_change(%{transaction: params})
    view |> element(~s(form[phx-submit="submit"])) |> render_submit(%{transaction: params})

    {:ok, transaction} = Transactions.get_transaction(scope, id: transaction.id)
    assert [%{amount: first}, %{amount: second}] = transaction.budget_allocations
    assert Decimal.eq?(first, "-3.00")
    assert Decimal.eq?(second, "-2.00")
  end

  test "closes the details form", %{conn: conn, scope: scope, attrs: attrs} do
    {:ok, transaction} =
      Transactions.create_transaction(scope, Map.put(attrs, "name", "Coffee"))

    {:ok, view, _html} = live(conn, ~p"/transactions")

    view |> element(~s(li[phx-value-id="#{transaction.id}"])) |> render_click()
    html = render_click(view, "close", %{})

    refute html =~ ~s(phx-submit="submit")
  end

  test "shows excluded transactions when the option is toggled on", %{
    conn: conn,
    scope: scope,
    attrs: attrs
  } do
    {:ok, transaction} =
      Transactions.create_transaction(scope, Map.put(attrs, "name", "Refund"))

    {:ok, _excluded} =
      Transactions.update_transaction(scope, transaction, %{"excluded" => true})

    {:ok, view, _html} = live(conn, ~p"/transactions")

    refute render(view) =~ "Refund"

    assert render_click(view, "change_excluded_option", %{}) =~ "Refund"
  end

  # The list pages as it is scrolled, so the page moves with the viewport rather than a button.
  test "pages through the list as it is scrolled", %{conn: conn, scope: scope, attrs: attrs} do
    {:ok, _coffee} = Transactions.create_transaction(scope, Map.put(attrs, "name", "Coffee"))

    {:ok, view, _html} = live(conn, ~p"/transactions")

    refute render_click(view, "next-page", %{}) =~ "Coffee"
    assert render_click(view, "prev-page", %{}) =~ "Coffee"
  end

  # The row can be gone by the time the delete lands, and deleting the rest still has to work.
  test "deletes what is left when a selected transaction is already gone", %{
    conn: conn,
    scope: scope,
    attrs: attrs
  } do
    {:ok, transaction} =
      Transactions.create_transaction(scope, Map.put(attrs, "name", "Coffee"))

    {:ok, view, _html} = live(conn, ~p"/transactions")

    render_click(view, "toggle_select_transaction", %{"id" => transaction.id, "value" => "on"})
    {:ok, _deleted} = Transactions.delete_transaction(scope, transaction)

    render_click(view, "delete", %{})

    assert [] = Transactions.list_transactions(scope)
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
