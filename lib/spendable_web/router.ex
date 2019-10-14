defmodule SpendableWeb.Router do
  use SpendableWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug Guardian.Plug.Pipeline, module: Spendable.Guardian, error_handler: SpendableWeb.AuthErrorHandler
    plug(Guardian.Plug.VerifyHeader, realm: "Bearer")
    plug(Guardian.Plug.LoadResource, allow_blank: true)
    plug SpendableWeb.Context
  end

  scope "/" do
    pipe_through :api

    forward "/graphiql", Absinthe.Plug.GraphiQL, schema: SpendableWeb.Schema
    forward "/graphql", Absinthe.Plug, schema: SpendableWeb.Schema
  end
end
