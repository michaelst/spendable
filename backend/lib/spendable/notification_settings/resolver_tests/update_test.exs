defmodule Spendable.Notifications.Settings.Resolver.UpdateTest do
  use Spendable.Web.ConnCase, async: true

  test "update device token" do
    user = insert(:user)

    notification_settings =
      insert(:notification_settings, user: user, device_token: "test-device-token", enabled: false)

    query = """
      mutation {
        updateNotificationSettings(id: "#{notification_settings.id}", enabled: true) {
          enabled
        }
      }
    """

    assert {:ok,
            %{
              data: %{
                "updateNotificationSettings" => %{
                  "enabled" => true
                }
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{current_user: user})
  end
end
