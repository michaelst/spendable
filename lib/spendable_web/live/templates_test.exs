defmodule SpendableWeb.Live.TemplatesTest do
  use SpendableWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias Spendable.Factory
  alias Spendable.BudgetAllocationTemplate

  test "LIVE /templates", %{conn: conn} do
    user = Factory.user()
    %{id: budget_id} = Factory.budget(user)

    conn =
      conn
      |> Plug.Test.init_test_session(%{})
      |> put_session(:current_user_id, user.id)

    conn = get(conn, "/templates")
    assert html_response(conn, 200)

    {:ok, view, _html} = live(conn)

    # creating templates
    view
    |> element(~s(#new-template))
    |> render_click()

    amount = Decimal.new("10.00")

    form = %{
      "name" => "Paycheck",
      "budget_allocation_template_lines" => %{
        "0" => %{
          "amount" => to_string(amount),
          "budget_id" => budget_id
        }
      }
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
                name: "Paycheck",
                budget_allocation_template_lines: [
                  %{
                    amount: ^amount,
                    budget_id: ^budget_id
                  }
                ]
              }
            ]} = Spendable.Api.read(BudgetAllocationTemplate, load: :budget_allocation_template_lines)

    # create a second template
    view
    |> element(~s(#new-template))
    |> render_click()

    view
    |> element(~s(form[phx-submit="submit"]))
    |> render_submit(%{
      form: %{
        "name" => "Another",
        "budget_allocation_template_lines" => %{
          "0" => %{
            "amount" => to_string(amount),
            "budget_id" => budget_id
          }
        }
      }
    })

    # editing templates
    view
    |> element(~s(li[phx-value-id="#{id}"]))
    |> render_click()

    view
    |> element(~s(form[phx-submit="submit"]))
    |> render_submit(%{
      form: %{
        "name" => "Paycheck Template",
        "budget_allocation_template_lines" => %{
          "0" => %{
            "amount" => to_string(amount),
            "budget_id" => budget_id
          }
        }
      }
    })

    assert {:ok, %{name: "Paycheck Template"}} = Spendable.Api.get(BudgetAllocationTemplate, id)

    # selecting templates
    view
    |> element(~s(input[phx-click="check_template"][phx-value-id="#{id}"]))
    |> render_click()

    view
    |> element(~s(input[phx-click="uncheck_template"][phx-value-id="#{id}"]))
    |> render_click()

    assert {:ok, %{id: ^id}} = Spendable.Api.get(BudgetAllocationTemplate, id)

    # archiving templates
    view
    |> element(~s(input[phx-click="check_template"][phx-value-id="#{id}"]))
    |> render_click()

    view
    |> element(~s(#archive))
    |> render_click()

    assert {:error, _not_found} = Spendable.Api.get(BudgetAllocationTemplate, id)
  end
end
