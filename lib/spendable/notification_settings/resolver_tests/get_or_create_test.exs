defmodule Spendable.Notifications.Settings.Resolver.GetOrCreateTest do
  use Spendable.Web.ConnCase, async: true
  import Spendable.Factory

  test "register APNS device token", %{conn: conn} do
    {_user, token} = Spendable.TestUtils.create_user()

    query = """
      query {
        notificationSettings(deviceToken: "test-device-token-new") {
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
               "notificationSettings" => %{
                 "enabled" => false
               }
             }
           } == response
  end

  test "get existing APNS device token", %{conn: conn} do
    {user, token} = Spendable.TestUtils.create_user()
    insert(:notification_settings, user: user, device_token: "test-device-token", enabled: true)

    query = """
      query {
        notificationSettings(deviceToken: "test-device-token") {
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
               "notificationSettings" => %{
                 "enabled" => true
               }
             }
           } == response
  end
end
