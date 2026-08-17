defmodule Spendable.Budgets.Actions.UpdateBudget do
  @moduledoc false

  import Spendable.Budgets.Utils.CalculateBalances

  alias Spendable.Budgets
  alias Spendable.Budgets.Schemas.Budget
  alias Spendable.Repo
  alias Spendable.Scope

  @doc """
  The balance has to be calculated before the changeset runs: the adjustment it writes is the
  difference between the requested balance and the current one.

  A budget that funds itself is funded before the balance is read back, so switching funding on
  shows the month filled rather than waiting for the nightly job.
  """
  def update_budget(
        %Scope{user: %{id: user_id}} = scope,
        %Budget{user_id: user_id} = budget,
        attrs
      ) do
    budget
    |> calculate_balance()
    |> Budget.changeset(attrs)
    |> Repo.update()
    |> case do
      {:ok, updated} ->
        funded = fund_this_month(updated, scope)

        {:ok, calculate_balance(funded)}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def update_budget(_scope, _budget, _attrs), do: {:error, :not_authorized}

  # Funding a month is idempotent, so this only ever fills what this month has not filled yet.
  # Clearing the amount stops future months without unpicking what past months already put in.
  defp fund_this_month(%Budget{funding_amount: nil} = budget, _scope), do: budget

  defp fund_this_month(%Budget{} = budget, scope) do
    {:ok, _funded} = Budgets.fund_budgets(scope, Date.utc_today())

    budget
  end
end
