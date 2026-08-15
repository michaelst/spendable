defmodule SpendableWeb.Live.BudgetsTest do
  use SpendableWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias Spendable.Accounts
  alias Spendable.Budgets
  alias Spendable.Scope

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

    view |> element(~s(li[phx-value-id="#{budget.id}"])) |> render_click()

    view
    |> element(~s(form[phx-submit="submit"]))
    |> render_submit(%{budget: %{"name" => "Food", "type" => "envelope"}})

    assert [%{name: "Food"}] = Budgets.list_budgets(scope)
  end

  test "archives the checked budgets", %{conn: conn, scope: scope} do
    {:ok, budget} = Budgets.create_budget(scope, %{"name" => "Groceries"})

    {:ok, view, _html} = live(conn, ~p"/budgets")

    view
    |> element(~s(input[phx-click="check_budget"][phx-value-id="#{budget.id}"]))
    |> render_click()

    view |> element("#archive") |> render_click()

    assert [] = Budgets.list_budgets(scope)
  end

  test "leaves a budget alone when it is checked and then unchecked", %{
    conn: conn,
    scope: scope
  } do
    {:ok, budget} = Budgets.create_budget(scope, %{"name" => "Groceries"})

    {:ok, view, _html} = live(conn, ~p"/budgets")

    view
    |> element(~s(input[phx-click="check_budget"][phx-value-id="#{budget.id}"]))
    |> render_click()

    html =
      view
      |> element(~s(input[phx-click="uncheck_budget"][phx-value-id="#{budget.id}"]))
      |> render_click()

    # Nothing is selected, so there is nothing to archive and the button is gone with it.
    refute html =~ ~s(id="archive")
    assert [%{name: "Groceries"}] = Budgets.list_budgets(scope)
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
