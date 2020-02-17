defmodule Spendable.Notifcations.DeviceToken.Resolver.CreatePublicTokenTest do
  use Spendable.Web.ConnCase, async: true

  test "register APNS device token", %{conn: conn} do
    {_user, token} = Spendable.TestUtils.create_user()

    query = """
      mutation {
        registerDeviceToken(deviceToken: "test-device-token") {
          deviceToken
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
               "registerDeviceToken" => %{
                 "deviceToken" => "test-device-token"
               }
             }
           } = response
  end
end
