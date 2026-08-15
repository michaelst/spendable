defmodule SpendableWeb.Live.TemplatesTest do
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

  test "renders the template list", %{conn: conn, scope: scope} do
    {:ok, _template} = Budgets.create_template(scope, %{"name" => "Paycheck"})

    {:ok, _view, html} = live(conn, ~p"/templates")

    assert html =~ "Paycheck"
  end

  test "creates a template with a line", %{conn: conn, scope: scope, budget: budget} do
    {:ok, view, _html} = live(conn, ~p"/templates")

    view |> element("#new-template") |> render_click()

    params = %{
      "name" => "Paycheck",
      "lines_sort" => ["0"],
      "budget_allocation_template_lines" => %{
        "0" => %{"amount" => "10.00", "budget_id" => budget.id}
      }
    }

    view |> element(~s(form[phx-submit="submit"])) |> render_change(%{template: params})
    view |> element(~s(form[phx-submit="submit"])) |> render_submit(%{template: params})

    assert [%{name: "Paycheck"} = template] = Budgets.list_templates(scope)
    {:ok, template} = Budgets.get_template(scope, template.id)
    assert [%{amount: amount}] = template.budget_allocation_template_lines
    assert Decimal.eq?(amount, "10.00")
  end

  test "keeps the form open and reports the error when the name is blank", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/templates")

    view |> element("#new-template") |> render_click()

    html =
      view
      |> element(~s(form[phx-submit="submit"]))
      |> render_submit(%{template: %{"name" => ""}})

    assert html =~ "can&#39;t be blank"
  end

  # The Split button posts a new index in lines_sort rather than firing its own event.
  test "adds a blank line", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/templates")

    view |> element("#new-template") |> render_click()

    html =
      view
      |> element(~s(form[phx-submit="submit"]))
      |> render_change(%{
        template: %{
          "name" => "Paycheck",
          "lines_sort" => ["0", "new"],
          "budget_allocation_template_lines" => %{"0" => %{}}
        }
      })

    assert html =~ "budget_allocation_template_lines][1]"
  end

  test "edits a template", %{conn: conn, scope: scope, budget: budget} do
    {:ok, template} =
      Budgets.create_template(scope, %{
        "name" => "Paycheck",
        "budget_allocation_template_lines" => %{
          "0" => %{"amount" => "10.00", "budget_id" => budget.id}
        }
      })

    {:ok, view, _html} = live(conn, ~p"/templates")

    view |> element(~s(li[phx-value-id="#{template.id}"])) |> render_click()

    view
    |> element(~s(form[phx-submit="submit"]))
    |> render_submit(%{template: %{"name" => "Salary"}})

    assert [%{name: "Salary"}] = Budgets.list_templates(scope)
  end

  test "archives the checked templates", %{conn: conn, scope: scope} do
    {:ok, template} = Budgets.create_template(scope, %{"name" => "Paycheck"})

    {:ok, view, _html} = live(conn, ~p"/templates")

    view
    |> element(~s(input[phx-click="check_template"][phx-value-id="#{template.id}"]))
    |> render_click()

    view |> element("#archive") |> render_click()

    assert [] = Budgets.list_templates(scope)
  end

  test "leaves a template alone when it is checked and then unchecked", %{
    conn: conn,
    scope: scope
  } do
    {:ok, template} = Budgets.create_template(scope, %{"name" => "Paycheck"})

    {:ok, view, _html} = live(conn, ~p"/templates")

    view
    |> element(~s(input[phx-click="check_template"][phx-value-id="#{template.id}"]))
    |> render_click()

    html =
      view
      |> element(~s(input[phx-click="uncheck_template"][phx-value-id="#{template.id}"]))
      |> render_click()

    refute html =~ ~s(id="archive")
    assert [%{name: "Paycheck"}] = Budgets.list_templates(scope)
  end

  test "filters the list by the search box", %{conn: conn, scope: scope} do
    {:ok, _paycheck} = Budgets.create_template(scope, %{"name" => "Paycheck"})
    {:ok, _bonus} = Budgets.create_template(scope, %{"name" => "Bonus"})

    {:ok, view, _html} = live(conn, ~p"/templates")

    html = render_change(view, "search", %{"search" => "pay"})

    assert html =~ "Paycheck"
    refute html =~ "Bonus"
  end
end
