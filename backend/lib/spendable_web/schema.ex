defmodule Spendable.Web.Schema do
  use Absinthe.Schema

  @apis [{Spendable.Api, Spendable.Api.Registry}]

  use AshGraphql, apis: @apis

  query do
  end

  mutation do
  end

  def context(ctx) do
    AshGraphql.add_context(ctx, @apis)
  end

  def plugins() do
    [Absinthe.Middleware.Dataloader | Absinthe.Plugin.defaults()]
  end
end
