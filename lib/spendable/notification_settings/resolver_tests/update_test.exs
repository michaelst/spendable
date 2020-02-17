defmodule Spendable.Notifications.Settings.Resolver.UpdateTest do
  use Spendable.Web.ConnCase, async: true
  import Spendable.Factory

  test "update device token", %{conn: conn} do
    {user, token} = Spendable.TestUtils.create_user()

    notification_settings =
      insert(:notification_settings, user: user, device_token: "test-device-token", enabled: false)

    query = """
      mutation {
        updateNotificationSettings(id: "#{notification_settings.id}", enabled: true) {
          enabled
        }
      }
    """

    response =
      conn
      |> put_req_header("authorization", "Bearer #{token}")
      |> post("/graphql", %{query: query})
      |> json_response(200)

    assert %{
             "data" => %{
               "updateNotificationSettings" => %{
                 "enabled" => true
               }
             }
           } == response
  end
end
