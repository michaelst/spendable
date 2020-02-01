defmodule Spendable.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  schema "transactions" do
    field :amount, :decimal
    field :date, :date
    field :name, :string
    field :note, :string

    belongs_to :bank_transaction, Spendable.Banks.Transaction
    belongs_to :category, Spendable.Banks.Category
    belongs_to :user, Spendable.User

    has_many :allocations, Spendable.Budgets.Allocation, on_replace: :delete

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, __schema__(:fields) -- [:id])
    |> cast_assoc(:allocations)
    |> validate_required([:user_id, :amount, :date])
  end
end
