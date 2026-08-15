defmodule Spendable.Budgets.Actions.UpdateBudget do
  @moduledoc false

  import Spendable.Budgets.Utils.CalculateBalances

  alias Spendable.Budgets.Schemas.Budget
  alias Spendable.Repo
  alias Spendable.Scope

  @doc """
  The balance has to be calculated before the changeset runs: the adjustment it writes is the
  difference between the requested balance and the current one.
  """
  def update_budget(
        %Scope{user: %{id: user_id}},
        %Budget{user_id: user_id} = budget,
        attrs
      ) do
    budget
    |> calculate_balance()
    |> Budget.changeset(attrs)
    |> Repo.update()
    |> case do
      {:ok, updated} -> {:ok, calculate_balance(updated)}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def update_budget(_scope, _budget, _attrs), do: {:error, :not_authorized}
end
