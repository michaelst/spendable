defmodule Spendable.NotificationSettings do
  use Ash.Resource,
    authorizers: [AshPolicyAuthorizer.Authorizer],
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  defmodule Provider do
    use Ash.Type.Enum, values: [:apns]
    def graphql_type(), do: :notification_provider
  end

  postgres do
    repo(Spendable.Repo)
    table "notification_settings"

    custom_indexes do
      index(["user_id"])
    end
  end

  attributes do
    integer_primary_key :id

    attribute :device_token, :string, allow_nil?: false, default: false
    attribute :enabled, :boolean, allow_nil?: false, default: false
    attribute :provider, Provider, allow_nil?: false, default: :apns

    timestamps()
  end

  identities do
    identity :device_token, [:device_token, :user_id]
  end

  relationships do
    belongs_to :user, Spendable.User, required?: true, field_type: :integer
  end

  actions do
    read :read, primary?: true

    read :get_by_device_token do
      argument :device_token, :string, allow_nil?: false
    end

    create :create do
      primary? true
      change relate_actor(:user)
    end

    update :update do
      primary? true
      accept [:enabled]
    end
  end

  graphql do
    type :notification_settings

    queries do
      get :notification_settings, :get_by_device_token, allow_nil?: false, identity: false
    end

    mutations do
      create :register_device_token, :create
      update :update_notification_settings, :update
    end
  end

  policies do
    policy always() do
      authorize_if action(:create)
      authorize_if attribute(:user_id, actor(:id))
    end
  end
end
