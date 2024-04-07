defmodule SpendableWeb.Live.BudgetsTest do
  use SpendableWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias Spendable.Budget
  alias Spendable.Factory

  test "LIVE /budgets", %{conn: conn} do
    user = Factory.user()

    conn =
      conn
      |> Plug.Test.init_test_session(%{})
      |> put_session(:current_user_id, user.id)

    conn = get(conn, "/budgets")
    assert html_response(conn, 200)

    {:ok, view, _html} = live(conn)

    # creating budgets
    view
    |> element(~s(#new-budget))
    |> render_click()

    form = %{
      "name" => "Groceries",
      "type" => "tracking"
    }

    view
    |> element(~s(form[phx-submit="submit"]))
    |> render_change(%{form: form})

    view
    |> element(~s(form[phx-submit="submit"]))
    |> render_submit(%{form: form})

    assert {:ok,
            [
              %{
                id: id,
                name: name,
                type: :tracking
              }
            ]} = Spendable.Api.read(Budget)

    assert to_string(name) == "Groceries"

    # create a second budget
    view
    |> element(~s(#new-budget))
    |> render_click()

    view
    |> element(~s(form[phx-submit="submit"]))
    |> render_submit(%{
      form: %{
        "name" => "Rent"
      }
    })

    # editing budgets
    view
    |> element(~s(li[phx-value-id="#{id}"]))
    |> render_click()

    view
    |> element(~s(form[phx-submit="submit"]))
    |> render_submit(%{
      form: %{
        "name" => "Food"
      }
    })

    assert {:ok, %{name: name}} = Spendable.Api.get(Budget, id)
    assert to_string(name) == "Food"

    # selecting budgets
    view
    |> element(~s(input[phx-click="check_budget"][phx-value-id="#{id}"]))
    |> render_click()

    view
    |> element(~s(input[phx-click="uncheck_budget"][phx-value-id="#{id}"]))
    |> render_click()

    assert {:ok, %{id: ^id}} = Spendable.Api.get(Budget, id)

    # archiving budgets
    view
    |> element(~s(input[phx-click="check_budget"][phx-value-id="#{id}"]))
    |> render_click()

    view
    |> element(~s(#archive))
    |> render_click()

    assert {:error, _not_found} = Spendable.Api.get(Budget, id)
  end
end
