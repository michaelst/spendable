defmodule Spendable.BankAccount do
  use Ash.Resource,
    authorizers: [AshPolicyAuthorizer.Authorizer],
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [Spendable.Notifiers.SyncMember]

  postgres do
    repo(Spendable.Repo)
    table "bank_accounts"
  end

  attributes do
    integer_primary_key :id

    attribute :balance, :decimal, allow_nil?: false
    attribute :external_id, :string, allow_nil?: false
    attribute :name, :string, allow_nil?: false
    attribute :number, :string
    attribute :sub_type, :string, allow_nil?: false
    attribute :sync, :boolean, allow_nil?: false, default: false
    attribute :type, :string, allow_nil?: false

    timestamps()
  end

  identities do
    identity :external_id, [:external_id]
  end

  relationships do
    belongs_to :user, Spendable.User, required?: true, private?: true, field_type: :integer
    belongs_to :bank_member, Spendable.BankMember, required?: true, field_type: :integer
  end

  actions do
    read :read, primary?: true

    update :update do
      primary? true
      accept [:sync]
    end
  end

  graphql do
    type :bank_account

    queries do
      get :bank_account, :read
      list :bank_accounts, :read
    end

    mutations do
      update :update_bank_account, :update
    end
  end

  policies do
    policy always() do
      authorize_if attribute(:user_id, actor(:id))
    end
  end
end
