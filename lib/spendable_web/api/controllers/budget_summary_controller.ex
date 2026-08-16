defmodule SpendableWeb.Api.BudgetSummaryController do
  use SpendableWeb, :api_controller

  alias Spendable.Banks
  alias Spendable.Budgets
  alias SpendableWeb.Api.Schemas.BudgetSummary
  alias SpendableWeb.Api.Schemas.Errors

  tags ["budgets"]

  operation :show,
    summary: "The budgets screen for one month",
    description: "Defaults to the current month. Any date in a month selects that whole month.",
    parameters: [
      month: [in: :query, type: %OpenApiSpex.Schema{type: :string, format: :date}],
      search: [in: :query, type: :string, description: "Matches on budget name."]
    ],
    responses: [
      ok: {"BudgetSummary", "application/json", BudgetSummary},
      unauthorized: {"Errors", "application/json", Errors},
      unprocessable_entity: {"Errors", "application/json", Errors}
    ]

  def show(conn, params) do
    scope = conn.assigns.current_scope
    summary = Budgets.calculate_month_summary(scope, month(params["month"]), search: params["search"])

    json(conn, BudgetSummary.build(credit_card_balance(summary, scope)))
  end

  defp month(month) when is_binary(month), do: Date.from_iso8601!(month)
  defp month(_month), do: Date.utc_today()

  # Card debt is not a budget, but the screen shows it beside them. It is only meaningful against
  # the current month, since it is what is owed right now.
  defp credit_card_balance(%{current_month: true} = summary, scope) do
    balance = scope |> Banks.calculate_credit_card_balance() |> Decimal.negate()

    Map.put(summary, :credit_card_balance, balance)
  end

  defp credit_card_balance(summary, _scope) do
    Map.put(summary, :credit_card_balance, Decimal.new("0.00"))
  end
end
