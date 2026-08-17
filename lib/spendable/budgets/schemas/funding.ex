defmodule Spendable.Budgets.Schemas.Funding do
  @moduledoc false
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

  def changeset(funding \\ %__MODULE__{}, attrs) do
    funding
    |> cast(attrs, [:amount, :month, :budget_id])
    |> validate_required([:amount, :month, :budget_id])
    |> put_beginning_of_month()
    |> validate_relationships([:budget])
  end

  # A funding belongs to a month, not a day, so any date in that month names the same row. Pinning
  # it here rather than in the caller is what makes the unique index on [:budget_id, :month] mean
  # "funded once this month".
  defp put_beginning_of_month(changeset) do
    case fetch_change(changeset, :month) do
      {:ok, %Date{} = month} -> put_change(changeset, :month, Date.beginning_of_month(month))
      _no_month -> changeset
    end
  end
end
