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
    plug OpenApiSpex.Plug.PutApiSpec, module: SpendableWeb.Api.ApiSpec
  end

  # A separate pipeline because the Plaid webhook shares `:api` and has to stay unauthenticated.
  pipeline :api_authenticated do
    plug SpendableWeb.Plugs.ApiAuth
  end

  pipeline :mcp do
    plug SpendableWeb.Plugs.VerifyMcpToken
  end

  pipeline :remember_return_to do
    plug SpendableWeb.Plugs.RememberReturnTo
  end

  live_session :oauth_consent, on_mount: [{SpendableWeb.Live.UserAuth, :ensure_authenticated}] do
    scope "/oauth", SpendableWeb.Live do
      pipe_through [:browser, :remember_return_to]

      live "/authorize", OAuthAuthorize
    end
  end

  scope "/.well-known", SpendableWeb do
    pipe_through :api

    get "/oauth-authorization-server", WellKnownController, :oauth_authorization_server
    # Both paths: the spec derives the resource's metadata URL by inserting the well-known prefix
    # before the resource path, but clients still probe the bare one.
    get "/oauth-protected-resource", WellKnownController, :oauth_protected_resource
    get "/oauth-protected-resource/mcp", WellKnownController, :oauth_protected_resource
  end

  scope "/oauth", SpendableWeb do
    pipe_through :api

    post "/token", OAuthController, :token
    post "/register", OAuthController, :register
  end

  scope "/mcp" do
    pipe_through :mcp

    forward "/", Anubis.Server.Transport.StreamableHTTP.Plug, server: SpendableWeb.MCP.Server
  end

  scope "/", SpendableWeb do
    pipe_through :browser

    get "/", AuthController, :login
    delete "/logout", AuthController, :delete

    get "/privacy-policy", PageController, :privacy_policy

    get "/banks/:id/logo", BankLogoController, :show
  end

  scope "/", SpendableWeb do
    pipe_through :api

    post "/plaid/webhook", PlaidController, :webhook
  end

  scope "/api" do
    pipe_through :api

    get "/openapi.json", OpenApiSpex.Plug.RenderSpec, []
  end

  scope "/api", SpendableWeb.Api do
    pipe_through :api

    post "/session", SessionController, :create
  end

  scope "/api", SpendableWeb.Api do
    pipe_through [:api, :api_authenticated]

    delete "/session", SessionController, :delete
    get "/me", MeController, :show

    # Ahead of "/budgets/:id" so the literal segment is not read as an id.
    get "/budgets/summary", BudgetSummaryController, :show
    resources "/budgets", BudgetController, only: [:index, :show, :create, :update, :delete]
    resources "/splits", SplitController, only: [:index, :show, :create, :update, :delete]

    # Ahead of "/transactions/:id" so the literal segments are not read as ids.
    patch "/transactions/bulk", TransactionBulkController, :update
    post "/transactions/bulk/delete", TransactionBulkController, :delete
    post "/transactions/transfer", TransactionTransferController, :create
    delete "/transactions/:id/transfer", TransactionTransferController, :delete

    resources "/transactions", TransactionController, only: [:index, :show, :create, :update, :delete]

    get "/banks", BankMemberController, :index
    post "/banks", BankMemberController, :create
    post "/banks/link_token", BankMemberController, :link_token
    post "/banks/:id/link_token", BankMemberController, :update_link_token
    post "/banks/:id/sync", BankMemberController, :sync
    get "/banks/:id/logo", BankLogoController, :show

    patch "/bank_accounts/:id", BankAccountController, :update
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
      live "/settings", Settings
    end
  end
end
