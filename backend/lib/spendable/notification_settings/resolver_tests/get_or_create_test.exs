defmodule Spendable.Notifications.Settings.Resolver.GetOrCreateTest do
  use Spendable.Web.ConnCase, async: true
  import Spendable.Factory

  test "register APNS device token" do
    user = insert(:user)

    query = """
      query {
        notificationSettings(deviceToken: "test-device-token-new") {
          enabled
        }
      }
    """

    assert {:ok,
            %{
              data: %{
                "notificationSettings" => %{
                  "enabled" => true
                }
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{current_user: user})
  end

  test "get existing APNS device token" do
    user = insert(:user)
    insert(:notification_settings, user: user, device_token: "test-device-token", enabled: true)

    query = """
      query {
        notificationSettings(deviceToken: "test-device-token") {
          enabled
        }
      }
    """

    assert {:ok,
            %{
              data: %{
                "notificationSettings" => %{
                  "enabled" => true
                }
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{current_user: user})
  end
end
