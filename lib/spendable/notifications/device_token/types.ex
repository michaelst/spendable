defmodule Spendable.Notificiations.DeviceToken.Types do
  use Absinthe.Schema.Notation

  alias Spendable.Middleware.CheckAuthentication
  alias Spendable.Middleware.LoadModel
  alias Spendable.Notifications.DeviceToken
  alias Spendable.Notifications.DeviceToken.Resolver

  object :device_token do
    field :enabled, :boolean
  end

  object :device_token_queries do
    field :device_token, :device_token do
      middleware(CheckAuthentication)
      arg(:device_token, non_null(:string))
      resolve(&Resolver.get_or_create/2)
    end
  end

  object :device_token_mutations do
    field :update_device_token, :device_token do
      middleware(CheckAuthentication)
      middleware(LoadModel, module: DeviceToken)
      arg(:id, non_null(:id))
      arg(:enabled, non_null(:boolean))
      resolve(&Resolver.update/2)
    end
  end
end
