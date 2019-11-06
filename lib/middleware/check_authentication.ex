defmodule Spendable.Middleware.CheckAuthentication do
  @behaviour Absinthe.Middleware

  alias Absinthe.Resolution

  def call(%{context: %{current_user: _}} = resolution, _config), do: resolution
  def call(resolution, _config), do: resolution |> Resolution.put_result({:error, "unauthenticated"})
end
