defmodule Budget.Banks.Account do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bank_members" do
    field :external_id, :string
    field :available_balance, :decimal
    field :balance, :decimal
    field :name, :string
    field :number, :string
    field :sub_type, :string
    field :type, :string

    belongs_to :user, Budget.User
    belongs_to :member, Budget.Member

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:external_id, :institution_id, :logo, :name, :plaid_token, :provider, :status, :user_id])
    |> validate_required([:name, :user_id, :external_id, :provider])
  end
end
