defmodule Spendable.Web.Controllers.WellKnownTest do
  use Spendable.Web.ConnCase, async: true

  test "apple app site association", %{conn: conn} do
    response =
      conn
      |> get("/.well-known/apple-app-site-association")
      |> json_response(200)

    assert response == %{
             "webcredentials" => %{
               "apps" => ["A4TA99R8XM.fiftysevenmedia.Spendable", "A4TA99R8XM.fiftysevenmedia.SpendableDev"]
             },
             "appLinks" => %{
               "apps" => [],
               "details" => [
                 %{
                   "appIDs" => ["A4TA99R8XM.fiftysevenmedia.Spendable", "A4TA99R8XM.fiftysevenmedia.SpendableDev"],
                   "components" => [%{"/" => "/plaid/oauth.html"}, %{"/" => "/plaid/oauth"}]
                 }
               ]
             }
           }
  end
end
