defmodule Spendable.Budget.Changes.SetAdjustment do
  use Ash.Resource.Change

  alias Spendable.BudgetAllocation
  alias Spendable.Utils

  require Logger

  def change(changeset, _opts, %{actor: user}) do
    current_balance = Ash.Changeset.get_data(changeset, :balance)
    current_adjustment = Ash.Changeset.get_data(changeset, :adjustment)
    new_balance = Ash.Changeset.get_argument(changeset, :balance) || current_balance
    adjustment = current_adjustment |> Decimal.add(new_balance) |> Decimal.sub(current_balance)

    changeset
    |> Ash.Changeset.change_attribute(:adjustment, adjustment)
    |> Ash.Changeset.after_action(fn _changeset, budget ->
      {:ok, Map.put(budget, :balance, new_balance)}
    end)
  end
end
