defmodule Spendable.User.Resolver do
  def current_user(_args, %{context: %{current_user: user}}) do
    {:ok, user}
  end
end
