defmodule Spendable.NotificationSettings.Factory do
  defmacro __using__(_opts) do
    quote do
      def notification_settings_factory() do
        %Spendable.NotificationSettings{
          device_token: "test-device-token",
          provider: :apns,
          inserted_at: DateTime.utc_now(),
          updated_at: DateTime.utc_now()
        }
      end
    end
  end
end
