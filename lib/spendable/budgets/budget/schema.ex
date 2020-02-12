defmodule Spendable.Budgets.Budget do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  alias Spendable.Budgets.Allocation
  alias Spendable.Repo

  schema "budgets" do
    field :adjustment, :decimal, default: Decimal.new("0.00")
    field :goal, :decimal
    field :name, :string
    field :balance, :decimal, virtual: true

    belongs_to :user, Spendable.User

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, [:adjustment, :goal, :name, :balance])
    |> validate_required([:user_id, :name])
    |> prepare_changes(fn
      %{data: %{id: id}, changes: %{balance: %Decimal{} = balance}} = changeset when is_integer(id) ->
        put_change(changeset, :adjustment, Decimal.sub(balance, allocated(id)))

      changeset ->
        changeset
    end)
  end

  def allocated(budget_id) do
    from(Allocation, where: [budget_id: ^budget_id])
    |> Repo.aggregate(:sum, :amount)
    |> case do
      nil -> Decimal.new("0.00")
      allocated -> allocated
    end
  end

  def balance(budget) do
    budget.id
    |> allocated()
    |> Decimal.add(budget.adjustment)
  end
end
