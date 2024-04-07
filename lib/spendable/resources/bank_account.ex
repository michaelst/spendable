defmodule Spendable.BankAccount do
  use Ash.Resource,
    authorizers: [Ash.Policy.Authorizer],
    data_layer: AshPostgres.DataLayer,
    notifiers: [Spendable.Notifiers.SyncMember]

  postgres do
    repo(Spendable.Repo)
    table "bank_accounts"

    custom_indexes do
      index(["bank_member_id"])
    end
  end

  identities do
    identity :external_id, [:user_id, :external_id]
  end

  attributes do
    uuid_primary_key :id

    attribute :balance, :decimal, allow_nil?: false
    attribute :external_id, :string, allow_nil?: false
    attribute :name, :string, allow_nil?: false
    attribute :number, :string
    attribute :sub_type, :string, allow_nil?: false
    attribute :sync, :boolean, allow_nil?: false, default: true
    attribute :type, :string, allow_nil?: false

    timestamps()
  end

  relationships do
    belongs_to :user, Spendable.User, allow_nil?: false
    belongs_to :bank_member, Spendable.BankMember, allow_nil?: false
  end

  actions do
    defaults [:read, :create, :update]
  end

  policies do
    policy always() do
      authorize_if expr(user_id == ^actor(:id))
    end
  end
end
