defmodule Spendable.Notifications.DeviceToken.Factory do
  defmacro __using__(_opts) do
    quote do
      def device_token_factory do
        %Spendable.Notifications.DeviceToken{
          device_token: "test-device-token"
        }
      end
    end
  end
end
