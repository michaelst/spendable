defmodule Spendable.Notificiations.DeviceToken.Types do
  use Absinthe.Schema.Notation

  alias Spendable.Notificiations.DeviceToken
  alias Spendable.Notificiations.DeviceToken.Resolver

  object :device_token do
    field :register, :device_token do
      middleware(CheckAuthentication)
      arg(:device_token, :string)
      resolve(&Resolver.create/2)
    end
  end
end
