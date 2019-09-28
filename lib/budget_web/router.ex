defmodule BudgetWeb.Router do
  use BudgetWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/" do
    pipe_through :api

    forward "/graphiql", Absinthe.Plug.GraphiQL, schema: BudgetWeb.Schema
    forward "/", Absinthe.Plug, schema: BudgetWeb.Schema
  end
end
