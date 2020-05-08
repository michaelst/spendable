defmodule Spendable.Budgets.Budget do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  alias Spendable.Budgets.Allocation
  alias Spendable.Budgets.AllocationTemplateLine
  alias Spendable.Repo

  schema "budgets" do
    field :adjustment, :decimal, default: Decimal.new("0.00")
    field :balance, :decimal, virtual: true
    field :goal, :decimal
    field :name, :string

    belongs_to :user, Spendable.User
    has_many :allocations, Allocation
    has_many :allocation_template_lines, AllocationTemplateLine

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, [:adjustment, :goal, :name, :balance])
    |> validate_required([:user_id, :name])
    |> prepare_changes(fn
      %{data: %{id: nil}, changes: %{balance: %Decimal{} = balance}} = changeset ->
        put_change(changeset, :adjustment, balance)

      %{data: %{id: id}, changes: %{balance: %Decimal{} = balance}} = changeset ->
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
