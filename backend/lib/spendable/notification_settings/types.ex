defmodule Spendable.Notifications.Settings.Types do
  use Absinthe.Schema.Notation

  alias Spendable.Middleware.CheckAuthentication
  alias Spendable.Middleware.LoadModel
  alias Spendable.Notifications.Settings
  alias Spendable.Notifications.Settings.Resolver

  object :notification_settings do
    field :id, :id
    field :enabled, :boolean
  end

  object :notification_settings_queries do
    field :notification_settings, :notification_settings do
      middleware(CheckAuthentication)
      arg(:device_token, non_null(:string))
      resolve(&Resolver.get_or_create/2)
    end
  end

  object :notification_settings_mutations do
    field :update_notification_settings, :notification_settings do
      middleware(CheckAuthentication)
      middleware(LoadModel, module: Settings)
      arg(:id, non_null(:id))
      arg(:enabled, non_null(:boolean))
      resolve(&Resolver.update/2)
    end
  end
end
