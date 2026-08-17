defmodule Spendable.Budgets.Schemas.Funding do
  @moduledoc """
  What one month put into one budget.

  There is no changeset: a funding is never written one at a time from user input. `fund_budgets/2`
  inserts a month for every budget at once, which is what lets the unique index on
  `[:budget_id, :month]` make funding a month safe to repeat.
  """
  use Spendable.Schema

  alias Spendable.Accounts.Schemas.User
  alias Spendable.Budgets.Schemas.Budget

  @primary_key {:id, UXID, autogenerate: true, prefix: "fnd"}
  schema "fundings" do
    field :amount, :decimal
    field :month, :date

    belongs_to :budget, Budget
    belongs_to :user, User

    timestamps()
  end
end
