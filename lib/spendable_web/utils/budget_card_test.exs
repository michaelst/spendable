defmodule SpendableWeb.Utils.BudgetCardTest do
  use ExUnit.Case, async: true

  import Spendable.Utils
  import SpendableWeb.Utils.BudgetCard

  alias Spendable.Budgets.Schemas.Budget

  # The iOS client reaches these same answers in Dart, so the table is what keeps the two honest.
  # mobile/test/budgets/budget_card_test.dart reads the same file.
  @fixtures "shared/budget_cards.json" |> File.read!() |> Jason.decode!()

  for fixture <- @fixtures["cards"] do
    @fixture fixture

    test @fixture["name"] do
      budgeted_amount = @fixture["budget"]["budgeted_amount"]
      funding_amount = @fixture["budget"]["funding_amount"]

      budget = %Budget{
        type: String.to_existing_atom(@fixture["budget"]["type"]),
        balance: Decimal.new(@fixture["budget"]["balance"]),
        budgeted_amount: budgeted_amount && Decimal.new(budgeted_amount),
        funding_amount: funding_amount && Decimal.new(funding_amount)
      }

      month =
        Map.new(@fixture["month"], fn {figure, amount} ->
          {String.to_existing_atom(figure), Decimal.new(amount)}
        end)

      card = build_budget_card(budget, month, @fixture["current_month"])

      assert card.label == @fixture["card"]["label"]
      assert card.percent == @fixture["card"]["percent"]
      assert card.bar == @fixture["card"]["bar"]
      assert card.footer == @fixture["card"]["footer"]
      assert Decimal.equal?(card.amount, Decimal.new(@fixture["card"]["amount"]))
    end
  end

  for fixture <- @fixtures["currency"] do
    @currency fixture

    test "formats #{inspect(fixture["amount"])} as #{fixture["formatted"]}" do
      amount = @currency["amount"] && Decimal.new(@currency["amount"])

      assert format_currency(amount) == @currency["formatted"]
    end
  end
end
