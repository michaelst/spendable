defmodule Spendable.NotificationSettings.Factory do
  def default() do
    %{
      device_token: "test-device-token",
      provider: :apns
    }
  end
end
