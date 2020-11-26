defmodule Spendable.Budgets.AllocationTemplate do
  use Ecto.Schema
  import Ecto.Changeset

  schema "budget_allocation_templates" do
    field :name, :string

    belongs_to :user, Spendable.User

    has_many :lines, Spendable.Budgets.AllocationTemplateLine,
      on_replace: :delete,
      foreign_key: :budget_allocation_template_id

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, __schema__(:fields) -- [:id])
    |> Spendable.Utils.Changeset.propogate_relation_id(:lines, :user_id)
    |> cast_assoc(:lines)
    |> validate_required([:user_id, :name])
  end
end
