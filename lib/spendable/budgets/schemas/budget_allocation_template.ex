defmodule Spendable.Budgets.Schemas.BudgetAllocationTemplate do
  @moduledoc false
  use Spendable.Schema

  alias Spendable.Accounts.Schemas.User
  alias Spendable.Budgets.Schemas.BudgetAllocationTemplateLine

  @primary_key {:id, UXID, autogenerate: true, prefix: "bat"}
  schema "budget_allocation_templates" do
    field :name, :string
    field :archived_at, :utc_datetime_usec

    belongs_to :user, User

    has_many :budget_allocation_template_lines, BudgetAllocationTemplateLine,
      on_replace: :delete,
      preload_order: [asc: :inserted_at]

    timestamps()
  end

  def changeset(template \\ %__MODULE__{}, attrs) do
    template
    |> cast(attrs, [:name])
    |> validate_required([:name])
    # Stamp the owner onto each line so a posted budget_id is checked against it.
    |> cast_assoc(:budget_allocation_template_lines,
      with: &BudgetAllocationTemplateLine.changeset(%{&1 | user_id: template.user_id}, &2),
      sort_param: :lines_sort,
      drop_param: :lines_drop
    )
  end

  def archive_changeset(template, attrs) do
    cast(template, attrs, [:archived_at])
  end
end
