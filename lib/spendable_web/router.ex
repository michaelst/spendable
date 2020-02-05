defmodule Spendable.Web.Router do
  use Spendable.Web, :router

  pipeline(:api) do
    plug :accepts, ["json"]
    plug Guardian.Plug.Pipeline, module: Spendable.Guardian
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource, allow_blank: true
    plug Spendable.Web.Context
    plug Spendable.Web.HttpRedirect
  end

  pipeline(:public) do
    plug :accepts, ["json"]
    plug Spendable.Web.HttpRedirect
  end

  forward "/_health", HealthCheck

  scope "/", Spendable.Web.Controllers do
    pipe_through :public

    get("/.well-known/apple-app-site-association", WellKnown, :apple_app_site_association)
    get("/privacy-policy", Site, :privacy_policy)
  end

  scope "/" do
    pipe_through :api

    forward "/graphql", Absinthe.Plug,
      schema: Spendable.Web.Schema,
      analyze_complexity: true,
      max_complexity: 500,
      pipeline: {Spendable.Web.Schema, :pipeline}
  end
end
