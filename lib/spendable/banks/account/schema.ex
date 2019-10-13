defmodule Spendable.Banks.Account do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bank_accounts" do
    field :external_id, :string
    field :available_balance, :decimal
    field :balance, :decimal
    field :name, :string
    field :number, :string
    field :sub_type, :string
    field :sync, :boolean, default: false
    field :type, :string

    belongs_to :user, Spendable.User
    belongs_to :bank_member, Spendable.Banks.Member

    timestamps()
  end

  @doc false
  def changeset(model, attrs) do
    model
    |> cast(attrs, __schema__(:fields) -- [:id])
    |> validate_required([:name, :user_id, :external_id, :bank_member_id, :sub_type, :type])
  end
end
