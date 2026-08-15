defmodule Spendable.Banks.Actions.CalculateCreditCardBalanceTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Banks
  alias Spendable.Scope

  setup do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    %{scope: Scope.for_user(user)}
  end

  test "is zero with no accounts", %{scope: scope} do
    assert Decimal.eq?(Banks.calculate_credit_card_balance(scope), 0)
  end
end
