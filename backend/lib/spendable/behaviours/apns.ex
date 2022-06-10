defmodule Spendable.Behaviour.APNS do
  alias Pigeon.APNS

  @callback push(APNS.notification()) :: APNS.notification() | :ok
  @callback push(APNS.notification(), APNS.push_opts()) :: APNS.notification() | :ok
end
