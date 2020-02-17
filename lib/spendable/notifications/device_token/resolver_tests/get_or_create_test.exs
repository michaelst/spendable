defmodule Spendable.Notifications.DeviceToken.Resolver.GetOrCreateTest do
  use Spendable.Web.ConnCase, async: true
  import Spendable.Factory

  test "register APNS device token", %{conn: conn} do
    {_user, token} = Spendable.TestUtils.create_user()

    query = """
      query {
        deviceToken(deviceToken: "test-device-token-new") {
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
               "deviceToken" => %{
                 "enabled" => false
               }
             }
           } == response
  end

  test "get existing APNS device token", %{conn: conn} do
    {user, token} = Spendable.TestUtils.create_user()
    insert(:device_token, user: user, device_token: "test-device-token", enabled: true)

    query = """
      query {
        deviceToken(deviceToken: "test-device-token") {
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
               "deviceToken" => %{
                 "enabled" => true
               }
             }
           } == response
  end
end
