defmodule Spendable.Notifications.Settings.Factory do
  defmacro __using__(_opts) do
    quote do
      def notification_settings_factory() do
        %Spendable.Notifications.Settings{
          device_token: "test-device-token",
          provider: :apns
        }
      end
    end
  end
end
