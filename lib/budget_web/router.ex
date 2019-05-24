defmodule BudgetWeb.Router do
  use BudgetWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Budget.Controllers do
    pipe_through :api

    post "/users", UserController, :create
  end
end
