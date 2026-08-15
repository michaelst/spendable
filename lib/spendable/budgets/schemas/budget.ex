defmodule Spendable.Budgets.Schemas.Budget do
  @moduledoc false
  use Spendable.Schema

  alias Spendable.Accounts.Schemas.User
  alias Spendable.Budgets.Schemas.BudgetAllocation
  alias Spendable.Budgets.Schemas.BudgetAllocationTemplateLine

  @types [:tracking, :envelope, :goal]

  @primary_key {:id, UXID, autogenerate: true, prefix: "bgt"}
  schema "budgets" do
    field :name, :string
    field :adjustment, :decimal, default: Decimal.new("0.00")
    field :budgeted_amount, :decimal
    field :type, Ecto.Enum, values: @types, default: :envelope
    field :archived_at, :utc_datetime_usec

    # Derived from the allocations rather than stored, so it is filled in on read.
    field :balance, :decimal, virtual: true

    belongs_to :user, User

    has_many :budget_allocations, BudgetAllocation
    has_many :budget_allocation_template_lines, BudgetAllocationTemplateLine

    timestamps()
  end

  def changeset(budget \\ %__MODULE__{}, attrs) do
    budget
    |> cast(attrs, [:name, :budgeted_amount, :type, :balance])
    |> validate_required([:name, :type])
    |> put_adjustment()
  end

  def archive_changeset(budget, attrs) do
    cast(budget, attrs, [:archived_at])
  end

  def types(), do: @types

  # A user edits the balance, never the adjustment: the adjustment absorbs the gap between
  # the balance they asked for and what the allocations already add up to.
  defp put_adjustment(changeset) do
    case fetch_change(changeset, :balance) do
      {:ok, %Decimal{} = new_balance} ->
        current_balance = changeset.data.balance || Decimal.new("0.00")
        current_adjustment = changeset.data.adjustment || Decimal.new("0.00")

        put_change(
          changeset,
          :adjustment,
          current_adjustment |> Decimal.add(new_balance) |> Decimal.sub(current_balance)
        )

      _no_requested_balance ->
        changeset
    end
  end
end
