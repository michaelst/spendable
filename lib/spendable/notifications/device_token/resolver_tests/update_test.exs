defmodule Spendable.Notifications.DeviceToken.Resolver.UpdateTest do
  use Spendable.Web.ConnCase, async: true
  import Spendable.Factory

  test "update device token", %{conn: conn} do
    {user, token} = Spendable.TestUtils.create_user()
    device_token = insert(:device_token, user: user, device_token: "test-device-token", enabled: false)

    query = """
      mutation {
        updateDeviceToken(id: "#{device_token.id}", enabled: true) {
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
               "updateDeviceToken" => %{
                 "enabled" => true
               }
             }
           } == response
  end
end
