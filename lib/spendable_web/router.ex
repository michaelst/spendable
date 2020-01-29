defmodule Spendable.Web.Router do
  use Spendable.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug Guardian.Plug.Pipeline, module: Spendable.Guardian
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource, allow_blank: true
    plug Spendable.Web.Context
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
