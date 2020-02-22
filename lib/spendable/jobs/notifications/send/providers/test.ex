defmodule Notifications.Provider.Test do
  @behaviour Notifications.Provider

  alias Spendable.Notifications.Settings

  @impl Notifications.Provider
  def new(_message, %Settings{device_token: "test-device-token-" <> _}), do: %{response: :success}
  def new(_message, %Settings{device_token: "bad-device-token-" <> _}), do: %{response: :bad_device_token}

  @impl Notifications.Provider
  def push(%{response: :success}), do: :ok
  def push(%{response: :bad_device_token}), do: :invalid_token
end
