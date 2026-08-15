defmodule SpendableWeb.Router do
  use SpendableWeb, :router

  forward "/_health", HealthCheck

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {SpendableWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SpendableWeb do
    pipe_through :browser

    get "/", AuthController, :login
    delete "/logout", AuthController, :delete

    get "/privacy-policy", PageController, :privacy_policy
  end

  scope "/", SpendableWeb do
    pipe_through :api

    post "/plaid/webhook", PlaidController, :webhook
  end

  scope "/auth", SpendableWeb do
    pipe_through :browser

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
  end

  live_session :authenticated,
    on_mount: [
      {SpendableWeb.Live.UserAuth, :ensure_authenticated},
      SpendableWeb.Live.Nav
    ] do
    scope "/", SpendableWeb.Live do
      pipe_through [:browser]

      live "/budgets", Budgets
      live "/transactions", Transactions
      live "/splits", Splits
      live "/banks", Banks
    end
  end
end
