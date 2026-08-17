defmodule Spendable.Budgets.Actions.CalculateFunded do
  @moduledoc false

  import Ecto.Query

  alias Spendable.Budgets.Schemas.Funding
  alias Spendable.Repo
  alias Spendable.Scope

  @zero Decimal.new("0.00")

  @doc """
  What each of the given budgets was funded with in one month, keyed by budget id.

  The companion to `calculate_spent/3`: that says what left a budget this month, this says what
  went into it. Every id asked for comes back, at zero if the month never funded it.
  """
  def calculate_funded(_scope, [], _month), do: %{}

  def calculate_funded(%Scope{user: %{id: user_id}}, budgets, month) do
    month = Date.beginning_of_month(month)
    budget_ids = Enum.map(budgets, & &1.id)

    funded =
      from(funding in Funding,
        select: {funding.budget_id, coalesce(sum(funding.amount), ^@zero)},
        where: funding.user_id == ^user_id,
        where: funding.budget_id in ^budget_ids,
        where: funding.month == ^month,
        group_by: funding.budget_id
      )
      |> Repo.all()
      |> Map.new()

    Map.new(budget_ids, &{&1, Map.get(funded, &1, @zero)})
  end
end
