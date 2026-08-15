defmodule Spendable.Banks do
  @moduledoc false

  alias Spendable.Banks.Actions

  defdelegate calculate_credit_card_balance(scope), to: Actions.CalculateCreditCardBalance
end
