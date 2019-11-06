defmodule Spendable.Middleware.LoadModel do
  @behaviour Absinthe.Middleware

  alias Spendable.Repo
  alias Absinthe.Resolution

  def call(%{context: %{current_user: user}, arguments: %{id: id}} = resolution, opts) do
    case Repo.get_by(opts[:module], id: id, user_id: user.id) do
      nil -> resolution |> Resolution.put_result({:error, "not found"})
      model -> %{resolution | context: Map.put(resolution.context, :model, model)}
    end
  end
end
