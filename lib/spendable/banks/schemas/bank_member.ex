defmodule Spendable.Banks.Schemas.BankMember do
  @moduledoc false
  use Spendable.Schema

  alias Spendable.Accounts.Schemas.User
  alias Spendable.Banks.Schemas.BankAccount

  @primary_key {:id, UXID, autogenerate: true, prefix: "bkm"}
  schema "bank_members" do
    field :external_id, :string
    field :institution_id, :string
    field :logo, :string
    field :name, :string
    field :provider, :string
    field :status, :string
    field :plaid_token, :string, redact: true
    field :history_token, :string

    belongs_to :user, User
    has_many :bank_accounts, BankAccount, preload_order: [asc: :name]

    timestamps()
  end

  def changeset(member \\ %__MODULE__{}, attrs) do
    member
    |> cast(attrs, [:external_id, :history_token, :institution_id, :logo, :name, :provider, :status])
    |> validate_required([:external_id, :name, :provider])
    |> unique_constraint(:external_id, name: :bank_members_user_id_external_id_index)
  end
end
