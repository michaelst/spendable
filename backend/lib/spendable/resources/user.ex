defmodule Spendable.User do
  use Ash.Resource,
    authorizers: [Ash.Policy.Authorizer],
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  alias Spendable.User.SpentByMonth

  postgres do
    repo(Spendable.Repo)
    table "users"
  end

  attributes do
    integer_primary_key :id

    attribute :bank_limit, :integer, default: 0, allow_nil?: false
    attribute :firebase_id, :string, private?: true, allow_nil?: false

    timestamps()
  end

  identities do
    identity :firebase_id, [:firebase_id]
  end

  calculations do
    calculate :plaid_link_token, :string, Spendable.User.Calculations.PlaidLinkToken, allow_nil?: false
    calculate :spendable, :decimal, Spendable.User.Calculations.Spendable, allow_nil?: false
    calculate :spent_by_month, {:array, SpentByMonth}, Spendable.User.Calculations.SpentByMonth, allow_nil?: false
  end

  actions do
    defaults [:read, :create]

    read :current_user do
      filter id: actor(:id)
    end
  end

  graphql do
    type :user

    queries do
      read_one :current_user, :current_user, allow_nil?: false
    end
  end

  policies do
    policy always() do
      authorize_if attribute(:id, actor(:id))
    end
  end
end
