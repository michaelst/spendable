defmodule Spendable.Budgets.Schemas.Split do
  @moduledoc false
  use Spendable.Schema

  alias Spendable.Accounts.Schemas.User
  alias Spendable.Budgets.Schemas.SplitLine

  @primary_key {:id, UXID, autogenerate: true, prefix: "spl"}
  schema "splits" do
    field :name, :string
    field :archived_at, :utc_datetime_usec

    belongs_to :user, User

    has_many :split_lines, SplitLine,
      on_replace: :delete,
      preload_order: [asc: :inserted_at]

    timestamps()
  end

  def changeset(split \\ %__MODULE__{}, attrs) do
    split
    |> cast(attrs, [:name])
    |> validate_required([:name])
    # Stamp the owner onto each line so a posted budget_id is checked against it.
    |> cast_assoc(:split_lines,
      with: &SplitLine.changeset(%{&1 | user_id: split.user_id}, &2),
      sort_param: :lines_sort,
      drop_param: :lines_drop
    )
  end

  def archive_changeset(split, attrs) do
    cast(split, attrs, [:archived_at])
  end
end
