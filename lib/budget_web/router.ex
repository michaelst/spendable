defmodule BudgetWeb.Router do
  use BudgetWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug Guardian.Plug.Pipeline, module: Budget.Guardian, error_handler: BudgetWeb.AuthErrorHandler
    plug(Guardian.Plug.VerifyHeader, realm: "Bearer")
    plug(Guardian.Plug.LoadResource, allow_blank: true)
    plug BudgetWeb.Context
  end

  scope "/" do
    pipe_through :api

    forward "/graphiql", Absinthe.Plug.GraphiQL, schema: BudgetWeb.Schema
    forward "/", Absinthe.Plug, schema: BudgetWeb.Schema
  end
end
