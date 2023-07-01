defmodule Spendable.NotificationSettings.GraphQLTests do
  use Spendable.DataCase, async: true

  test "get existing APNS device token" do
    user = Factory.insert(Spendable.User)
    Factory.insert(Spendable.NotificationSettings, user_id: user.id, device_token: "test-device-token", enabled: true)

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
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{actor: user})
  end

  test "register APNS device token" do
    user = Factory.insert(Spendable.User)

    query = """
      mutation {
        registerDeviceToken(input: { deviceToken: "test-device-token-new", provider: APNS, enabled: true }) {
          result {
            enabled
          }
        }
      }
    """

    assert {:ok,
            %{
              data: %{
                "registerDeviceToken" => %{
                  "result" => %{
                    "enabled" => true
                  }
                }
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{actor: user})
  end

  test "update device token" do
    user = Factory.insert(Spendable.User)

    notification_settings =
      Factory.insert(Spendable.NotificationSettings, user_id: user.id, device_token: "test-device-token", enabled: false)

    query = """
      mutation {
        updateNotificationSettings(id: "#{notification_settings.id}", input: { enabled: true }) {
          result {
            enabled
          }
        }
      }
    """

    assert {:ok,
            %{
              data: %{
                "updateNotificationSettings" => %{
                  "result" => %{
                    "enabled" => true
                  }
                }
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{actor: user})
  end
end
