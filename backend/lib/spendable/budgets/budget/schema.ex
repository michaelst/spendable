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

  def balance_by_budget(_module, budgets) do
    allocated = budgets |> Enum.map(& &1.id) |> allocated()

    budgets
    |> Enum.map(fn budget ->
      balance = allocated |> Map.get(budget.id, Decimal.new("0")) |> Decimal.add(budget.adjustment)
      {budget.id, balance}
    end)
    |> Map.new()
  end

  def allocated(budget_ids) when is_list(budget_ids) do
    from(a in Allocation,
      select: {a.budget_id, sum(a.amount)},
      group_by: a.budget_id,
      where: a.budget_id in ^budget_ids
    )
    |> Repo.all()
    |> Map.new()
  end

  def allocated(budget_id), do: allocated([budget_id])[budget_id] || "0.00"
end
