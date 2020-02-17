defmodule Spendable.Notificiations.DeviceToken.Types do
  use Absinthe.Schema.Notation

  alias Spendable.Middleware.CheckAuthentication
  alias Spendable.Notifcations.DeviceToken.Resolver

  object :device_token do
    field :device_token, :string
  end

  object :device_token_mutatinos do
    field :register_device_token, :device_token do
      middleware(CheckAuthentication)
      arg(:device_token, non_null(:string))
      resolve(&Resolver.register/2)
    end
  end
end
