defmodule SpendableWeb.Api.ApiSpec do
  @moduledoc false
  @behaviour OpenApiSpex.OpenApi

  alias OpenApiSpex.Components
  alias OpenApiSpex.Info
  alias OpenApiSpex.OpenApi
  alias OpenApiSpex.Paths
  alias OpenApiSpex.SecurityScheme
  alias OpenApiSpex.Server
  alias SpendableWeb.Router

  @impl OpenApiSpex.OpenApi
  def spec() do
    %OpenApi{
      info: %Info{
        title: "Spendable",
        description: "The API the Spendable mobile app runs on.",
        version: "1.0.0"
      },
      servers: [%Server{url: "https://spendable.money"}],
      paths: Paths.from_router(Router),
      components: %Components{
        securitySchemes: %{"bearer" => %SecurityScheme{type: "http", scheme: "bearer"}}
      },
      security: [%{"bearer" => []}]
    }
    |> OpenApiSpex.resolve_schema_modules()
  end
end
