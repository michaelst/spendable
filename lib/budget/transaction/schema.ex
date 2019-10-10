defmodule Budget.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  schema "transactions" do
    field :amount, :decimal
    field :date, :date
    field :name, :string
    field :note, :string

    belongs_to :category, Budget.Banks.Category
    belongs_to :user, Budget.User
    belongs_to :bank_transaction, Budget.Banks.Transaction

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, __schema__(:fields) -- [:id])
    |> validate_required([:user_id, :amount, :date])
  end
end
