defmodule Spendable.Budgets.Budget do
  use Ecto.Schema
  import Ecto.Changeset

  schema "budgets" do
    field :allocated, :decimal, default: Decimal.new("0.00")
    field :goal, :decimal
    field :name, :string

    belongs_to :user, Spendable.User

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, __schema__(:fields) -- [:id])
    |> validate_required([:user_id, :name])
  end
end
