defmodule Spendable.BankMember do
  use Ash.Resource,
    authorizers: [Ash.Policy.Authorizer],
    data_layer: AshPostgres.DataLayer,
    notifiers: [Spendable.Notifiers.SyncMember]

  alias Spendable.BankMember.Storage

  postgres do
    repo(Spendable.Repo)
    table "bank_members"

    custom_indexes do
      index(["user_id"])
    end
  end

  attributes do
    integer_primary_key :id

    attribute :external_id, :string, allow_nil?: false
    attribute :institution_id, :string
    attribute :logo, :string
    attribute :name, :ci_string, allow_nil?: false
    attribute :plaid_token, :string, allow_nil?: false, private?: true
    attribute :provider, :string, allow_nil?: false
    attribute :status, :string

    timestamps()
  end

  identities do
    identity :external_id, [:external_id]
  end

  relationships do
    belongs_to :user, Spendable.User, allow_nil?: false, attribute_type: :integer
    has_many :bank_accounts, Spendable.BankAccount, sort: :name
  end

  calculations do
    calculate :plaid_link_token, :string, Spendable.BankMember.Calculations.PlaidLinkToken,
      allow_nil?: false,
      select: [:user_id, :plaid_token]
  end

  actions do
    defaults [:read, :update]

    create :create_from_public_token do
      argument :public_token, :string, allow_nil?: false
      accept [:public_token]
      allow_nil_input [:external_id, :name, :provider]
      change relate_actor(:user)
      change Spendable.BankMember.Changes.CreateBankMember
    end
  end

  policies do
    policy always() do
      authorize_if action(:create_from_public_token)
      authorize_if expr(user_id == actor(:id))
    end
  end

  def list(user_id, opts) do
    Storage.list(user_id, opts)
  end
end
