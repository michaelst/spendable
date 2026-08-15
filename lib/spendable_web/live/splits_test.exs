defmodule SpendableWeb.Live.SplitsTest do
  use SpendableWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias Spendable.Accounts
  alias Spendable.Budgets
  alias Spendable.Scope

  setup %{conn: conn} do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    scope = Scope.for_user(user)
    {:ok, budget} = Budgets.create_budget(scope, %{"name" => "Groceries"})

    conn =
      conn
      |> Plug.Test.init_test_session(%{})
      |> put_session(:current_user_id, user.id)

    %{conn: conn, scope: scope, budget: budget}
  end

  test "renders the split list", %{conn: conn, scope: scope} do
    {:ok, _split} = Budgets.create_split(scope, %{"name" => "Paycheck"})

    {:ok, _view, html} = live(conn, ~p"/splits")

    assert html =~ "Paycheck"
  end

  test "creates a split with a line", %{conn: conn, scope: scope, budget: budget} do
    {:ok, view, _html} = live(conn, ~p"/splits")

    view |> element("#new-split") |> render_click()

    params = %{
      "name" => "Paycheck",
      "lines_sort" => ["0"],
      "split_lines" => %{
        "0" => %{"amount" => "10.00", "budget_id" => budget.id}
      }
    }

    view |> element(~s(form[phx-submit="submit"])) |> render_change(%{split: params})
    view |> element(~s(form[phx-submit="submit"])) |> render_submit(%{split: params})

    assert [%{name: "Paycheck"} = split] = Budgets.list_splits(scope)
    {:ok, split} = Budgets.get_split(scope, split.id)
    assert [%{amount: amount}] = split.split_lines
    assert Decimal.eq?(amount, "10.00")
  end

  test "keeps the form open and reports the error when the name is blank", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/splits")

    view |> element("#new-split") |> render_click()

    html =
      view
      |> element(~s(form[phx-submit="submit"]))
      |> render_submit(%{split: %{"name" => ""}})

    assert html =~ "can&#39;t be blank"
  end

  # The Split button posts a new index in lines_sort rather than firing its own event.
  test "adds a blank line", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/splits")

    view |> element("#new-split") |> render_click()

    html =
      view
      |> element(~s(form[phx-submit="submit"]))
      |> render_change(%{
        split: %{
          "name" => "Paycheck",
          "lines_sort" => ["0", "new"],
          "split_lines" => %{"0" => %{}}
        }
      })

    assert html =~ "split_lines][1]"
  end

  test "edits a split", %{conn: conn, scope: scope, budget: budget} do
    {:ok, split} =
      Budgets.create_split(scope, %{
        "name" => "Paycheck",
        "split_lines" => %{
          "0" => %{"amount" => "10.00", "budget_id" => budget.id}
        }
      })

    {:ok, view, _html} = live(conn, ~p"/splits")

    view |> element(~s(li[phx-value-id="#{split.id}"])) |> render_click()

    view
    |> element(~s(form[phx-submit="submit"]))
    |> render_submit(%{split: %{"name" => "Salary"}})

    assert [%{name: "Salary"}] = Budgets.list_splits(scope)
  end

  test "archives the checked splits", %{conn: conn, scope: scope} do
    {:ok, split} = Budgets.create_split(scope, %{"name" => "Paycheck"})

    {:ok, view, _html} = live(conn, ~p"/splits")

    view
    |> element(~s(input[phx-click="check_split"][phx-value-id="#{split.id}"]))
    |> render_click()

    view |> element("#archive") |> render_click()

    assert [] = Budgets.list_splits(scope)
  end

  test "leaves a split alone when it is checked and then unchecked", %{
    conn: conn,
    scope: scope
  } do
    {:ok, split} = Budgets.create_split(scope, %{"name" => "Paycheck"})

    {:ok, view, _html} = live(conn, ~p"/splits")

    view
    |> element(~s(input[phx-click="check_split"][phx-value-id="#{split.id}"]))
    |> render_click()

    html =
      view
      |> element(~s(input[phx-click="uncheck_split"][phx-value-id="#{split.id}"]))
      |> render_click()

    refute html =~ ~s(id="archive")
    assert [%{name: "Paycheck"}] = Budgets.list_splits(scope)
  end

  test "closes the details form", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/splits")

    view |> element("#new-split") |> render_click()
    html = render_click(view, "close", %{})

    refute html =~ ~s(phx-submit="submit")
  end

  test "filters the list by the search box", %{conn: conn, scope: scope} do
    {:ok, _paycheck} = Budgets.create_split(scope, %{"name" => "Paycheck"})
    {:ok, _bonus} = Budgets.create_split(scope, %{"name" => "Bonus"})

    {:ok, view, _html} = live(conn, ~p"/splits")

    html = render_change(view, "search", %{"search" => "pay"})

    assert html =~ "Paycheck"
    refute html =~ "Bonus"
  end
end
