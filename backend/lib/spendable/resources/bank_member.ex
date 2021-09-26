defmodule Spendable.BankMember do
  use Ash.Resource,
    authorizers: [AshPolicyAuthorizer.Authorizer],
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [Spendable.Notifiers.SyncMember]

  postgres do
    repo(Spendable.Repo)
    table "bank_members"

    custom_indexes do
      index ["user_id"]
    end
  end

  attributes do
    integer_primary_key :id

    attribute :external_id, :string, allow_nil?: false
    attribute :institution_id, :string
    attribute :logo, :string
    attribute :name, :string, allow_nil?: false
    attribute :plaid_token, :string, allow_nil?: false, private?: true
    attribute :provider, :string, allow_nil?: false
    attribute :status, :string

    timestamps()
  end

  identities do
    identity :external_id, [:external_id, :user_id]
  end

  relationships do
    belongs_to :user, Spendable.User, required?: true, field_type: :integer
    has_many :bank_accounts, Spendable.BankAccount, sort: :name
  end

  calculations do
    calculate :plaid_link_token, :string, Spendable.BankMember.Calculations.PlaidLinkToken,
      allow_nil?: false,
      select: [:user_id, :plaid_token]
  end

  actions do
    create :create_from_public_token do
      primary? true
      argument :public_token, :string, allow_nil?: false
      accept [:public_token]
      allow_nil_input [:external_id, :name, :provider]
      change relate_actor(:user)
      change Spendable.BankMember.Changes.CreateBankMember
    end

    create :create
    update :update, primary?: true
  end

  graphql do
    type :bank_member

    queries do
      get :bank_member, :read, allow_nil?: false
      list :bank_members, :read
    end

    mutations do
      create :create_bank_member, :create_from_public_token
    end
  end

  policies do
    policy always() do
      authorize_if action(:create_from_public_token)
      authorize_if attribute(:user_id, actor(:id))
    end
  end
end
