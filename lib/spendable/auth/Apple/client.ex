defmodule Apple do
  def client() do
    middleware = [
      {Tesla.Middleware.BaseUrl, "https://appleid.apple.com"},
      Tesla.Middleware.JSON
    ]

    Tesla.client(middleware)
  end

  def public_keys(), do: client() |> Tesla.get("/auth/keys")
end
