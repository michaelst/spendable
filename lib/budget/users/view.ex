defmodule Budget.UserView do
  use BudgetWeb, :view

  def render(:show, user), do: json(user)

  def json(user) do
    user
    |> Map.take([:id, :first_name, :last_name, :email])
    |> Map.put(:token, value)
  end
end
