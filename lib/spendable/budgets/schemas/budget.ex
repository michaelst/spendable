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
    |> clear_funding_amount()
    |> force_rollover()
    |> put_adjustment()
  end

  def archive_changeset(budget, attrs) do
    cast(budget, attrs, [:archived_at])
  end

  # Only a budget that holds money can fund itself. Tracking and income record a month and keep no
  # balance, so a funding amount on either would be money with nowhere to land.
  defp clear_funding_amount(changeset) do
    case get_field(changeset, :type) do
      type when type in [:tracking, :income] -> put_change(changeset, :funding_amount, nil)
      _holds_money -> changeset
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
