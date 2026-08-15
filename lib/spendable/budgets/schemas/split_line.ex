defmodule Spendable.Budgets.Schemas.SplitLine do
  @moduledoc false
  use Spendable.Schema

  alias Spendable.Accounts.Schemas.User
  alias Spendable.Budgets.Schemas.Budget
  alias Spendable.Budgets.Schemas.Split

  @primary_key {:id, UXID, autogenerate: true, prefix: "spll"}
  schema "split_lines" do
    field :amount, :decimal

    belongs_to :budget, Budget
    belongs_to :split, Split
    belongs_to :user, User

    timestamps()
  end

  def changeset(line \\ %__MODULE__{}, attrs) do
    line
    |> cast(attrs, [:amount, :budget_id])
    |> validate_required([:amount, :budget_id])
    |> validate_relationships([:budget])
  end
end
