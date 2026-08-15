defmodule Spendable.Budgets.Actions.CalculateSpentByMonthTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Budgets
  alias Spendable.Scope

  setup do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    %{scope: Scope.for_user(user)}
  end

  # The month picker always needs the current month, even before anything is spent in it.
  test "offers the current month with nothing spent", %{scope: scope} do
    current_month = Date.beginning_of_month(Date.utc_today())

    assert [%{month: ^current_month, spent: spent}] = Budgets.calculate_spent_by_month(scope)
    assert Decimal.eq?(spent, 0)
  end
end
