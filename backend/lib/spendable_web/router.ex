defmodule Spendable.Web.Router do
  use Spendable.Web, :router

  pipeline :api do
    plug :accepts, [:urlencoded, :multipart, :json]
    plug Spendable.Plug.Auth
    plug :put_secure_browser_headers
    plug Plug.Logger
  end

  pipeline :public do
    plug :accepts, ["json"]
    plug :put_secure_browser_headers
    plug Plug.Logger
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Plug.Logger
  end

  forward "/_health", HealthCheck

  scope "/", Spendable.Web.Controllers do
    pipe_through :public

    get "/.well-known/apple-app-site-association", WellKnown, :apple_app_site_association
    post "/plaid/webhook", Plaid, :webhook
  end

  scope "/", Spendable.Web.Controllers do
    pipe_through :browser

    get "/", Site, :index
    get "/privacy-policy", Site, :privacy_policy
    get "/contact-us", Site, :contact_us
  end

  scope "/" do
    pipe_through :api

    forward "/graphql", Absinthe.Plug,
      schema: Spendable.Web.Schema,
      analyze_complexity: true,
      max_complexity: 500
  end
end
