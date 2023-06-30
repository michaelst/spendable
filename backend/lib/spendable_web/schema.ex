defmodule Spendable.Web.Schema do
  use Absinthe.Schema

  @apis [Spendable.Api]

  use AshGraphql, apis: @apis

  query do
  end

  mutation do
  end

  def plugins() do
    [Absinthe.Middleware.Dataloader | Absinthe.Plugin.defaults()]
  end
end
