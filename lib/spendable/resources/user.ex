defmodule Spendable.User do
  use Ash.Resource,
    authorizers: [Ash.Policy.Authorizer],
    data_layer: AshPostgres.DataLayer

  alias Spendable.User.SpentByMonth

  postgres do
    repo(Spendable.Repo)
    table "users"
  end

  identities do
    identity :external_id, [:external_id]
  end

  attributes do
    uuid_primary_key :id

    attribute :bank_limit, :integer, default: 0, allow_nil?: false
    attribute :external_id, :string, allow_nil?: false
    attribute :image, :string
    attribute :provider, :string, allow_nil?: false

    timestamps()
  end

  calculations do
    calculate :plaid_link_token, :string, Spendable.User.Calculations.PlaidLinkToken, allow_nil?: false

    calculate :spendable, :decimal, Spendable.User.Calculations.Spendable, allow_nil?: false

    calculate :spent_by_month, {:array, SpentByMonth}, Spendable.User.Calculations.SpentByMonth, allow_nil?: false
  end

  actions do
    defaults [:read, :create]
  end

  policies do
    policy always() do
      authorize_if expr(id == ^actor(:id))
    end
  end
end
