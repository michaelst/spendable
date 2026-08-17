defmodule Spendable.Budgets.Actions.UpdateFunding do
  @moduledoc false

  alias Spendable.Budgets.Schemas.Budget
  alias Spendable.Budgets.Schemas.Funding
  alias Spendable.Repo
  alias Spendable.Scope

  @doc """
  Sets what one month put into one budget, whether or not the month funded it already.

  This is how a user deviates for a single month - "only 200 into groceries this time" - without
  changing what the budget funds itself with every other month. Setting it to zero is how a month
  is skipped, which is not the same as never having been funded: the row records the decision.
  """
  def update_funding(
        %Scope{user: %{id: user_id}},
        %Budget{user_id: user_id} = budget,
        %Date{} = month,
        amount
      ) do
    month = Date.beginning_of_month(month)

    case Repo.get_by(Funding, budget_id: budget.id, month: month, user_id: user_id) do
      %Funding{} = funding ->
        funding |> Funding.changeset(%{amount: amount}) |> Repo.update()

      nil ->
        %Funding{user_id: user_id}
        |> Funding.changeset(%{amount: amount, month: month, budget_id: budget.id})
        |> Repo.insert()
    end
  end

  def update_funding(_scope, _budget, _month, _amount), do: {:error, :not_authorized}
end
