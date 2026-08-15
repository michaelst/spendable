defmodule Spendable.Banks.Schemas.BankAccount do
  @moduledoc false
  use Spendable.Schema

  alias Spendable.Accounts.Schemas.User
  alias Spendable.Banks.Schemas.BankMember
  alias Spendable.Budgets.Schemas.Budget

  @primary_key {:id, UXID, autogenerate: true, prefix: "bka"}
  schema "bank_accounts" do
    field :external_id, :string
    field :balance, :decimal
    field :name, :string
    field :number, :string
    field :sub_type, :string
    field :type, :string
    field :sync, :boolean, default: true

    belongs_to :user, User
    belongs_to :bank_member, BankMember
    belongs_to :budget, Budget

    timestamps()
  end

  def changeset(account \\ %__MODULE__{}, attrs) do
    account
    |> cast(attrs, [:external_id, :balance, :name, :number, :sub_type, :type, :sync, :budget_id])
    |> validate_required([:external_id, :balance, :name, :sub_type, :type, :sync])
    |> validate_relationships([:budget])
    |> unique_constraint([:user_id, :external_id])
  end
end
