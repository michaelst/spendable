defmodule Spendable.Auth.Google do
  def client do
    middleware = [
      {Tesla.Middleware.BaseUrl, "https://www.googleapis.com"},
      Tesla.Middleware.JSON
    ]

    Tesla.client(middleware)
  end

  def get_firebase_public_keys do
    client()
    |> Tesla.get("robot/v1/metadata/x509/securetoken@system.gserviceaccount.com")
  end
end
