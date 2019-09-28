defmodule BudgetWeb.Context do
  @behaviour Plug

  def init(opts), do: opts

  def call(conn, _) do
    case Guardian.Plug.current_resource(conn) do
      nil -> conn
      user -> Absinthe.Plug.put_options(conn, context: %{current_user: user})
    end
  end
end
