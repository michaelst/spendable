defmodule Spendable.Banks.Member do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bank_members" do
    field :external_id, :string
    field :institution_id, :string
    field :logo, :string
    field :name, :string
    field :plaid_token, :string
    field :provider, :string
    field :status, :string

    belongs_to :user, Spendable.User
    has_many :bank_accounts, Spendable.Banks.Account, foreign_key: :bank_member_id

    timestamps()
  end

  @doc false
  def changeset(model, attrs) do
    model
    |> cast(attrs, [:external_id, :institution_id, :logo, :name, :plaid_token, :provider, :status, :user_id])
    |> validate_required([:name, :user_id, :external_id, :provider])
  end
end
