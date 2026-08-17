defmodule Spendable.Budgets.Schemas.Budget do
  @moduledoc false
  use Spendable.Schema

  alias Spendable.Accounts.Schemas.User
  alias Spendable.Budgets.Schemas.BudgetAllocation
  alias Spendable.Budgets.Schemas.Funding
  alias Spendable.Budgets.Schemas.SplitLine

  @types [:tracking, :envelope, :goal, :income]

  @primary_key {:id, UXID, autogenerate: true, prefix: "bgt"}
  schema "budgets" do
    field :name, :string
    field :adjustment, :decimal, default: Decimal.new("0.00")
    field :budgeted_amount, :decimal
    field :funding_amount, :decimal
    field :type, Ecto.Enum, values: @types, default: :envelope
    field :rollover, :boolean, default: true
    field :archived_at, :utc_datetime_usec

    # Derived from the allocations rather than stored, so it is filled in on read.
    field :balance, :decimal, virtual: true

    belongs_to :user, User

    has_many :budget_allocations, BudgetAllocation
    has_many :fundings, Funding
    has_many :split_lines, SplitLine

    timestamps()
  end

  def changeset(budget \\ %__MODULE__{}, attrs) do
    budget
    |> cast(attrs, [
      :name,
      :budgeted_amount,
      :funding_amount,
      :type,
      :rollover,
      :balance
    ])
    |> validate_required([:name, :type])
    |> clear_unused_amounts()
    |> force_rollover()
    |> put_adjustment()
  end

  def archive_changeset(budget, attrs) do
    cast(budget, attrs, [:archived_at])
  end

  # Each type carries exactly the amounts it means. An envelope has one - what a month puts in,
  # which is also what its spending is read against. A goal has two, because a target and a monthly
  # contribution are different numbers. Tracking and income hold nothing, so they only have a figure
  # to be measured against.
  defp clear_unused_amounts(changeset) do
    case get_field(changeset, :type) do
      :envelope -> put_change(changeset, :budgeted_amount, nil)
      :goal -> changeset
      _holds_nothing -> put_change(changeset, :funding_amount, nil)
    end
  end

  # Only an envelope can decline to roll over. A goal accumulates - that is what saving is - and
  # tracking and income keep no balance for a month to carry in the first place.
  defp force_rollover(changeset) do
    case get_field(changeset, :type) do
      :envelope -> changeset
      _accumulates -> put_change(changeset, :rollover, true)
    end
  end

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
