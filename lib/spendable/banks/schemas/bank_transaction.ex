defmodule Spendable.Banks.Schemas.BankTransaction do
  @moduledoc false
  use Spendable.Schema

  alias Spendable.Accounts.Schemas.User
  alias Spendable.Banks.Schemas.BankAccount
  alias Spendable.Transactions.Schemas.Transaction

  @primary_key {:id, UXID, autogenerate: true, prefix: "bkt"}
  schema "bank_transactions" do
    field :external_id, :string, redact: true
    field :amount, :decimal
    field :date, :date
    field :name, :string
    field :pending, :boolean

    belongs_to :user, User
    belongs_to :bank_account, BankAccount
    has_one :transaction, Transaction

    timestamps()
  end

  def changeset(bank_transaction \\ %__MODULE__{}, attrs) do
    bank_transaction
    |> cast(attrs, [:external_id, :amount, :date, :name, :pending])
    |> validate_required([:external_id, :amount, :date, :name, :pending])
    |> unique_constraint([:external_id, :bank_account_id])
  end
end
