defmodule Budget.UserView do
  use BudgetWeb, :view

  def render("show.json", user) do
    {:ok, token, _claims} = Budget.Guardian.encode_and_sign(user)

    user
    |> Map.take([:id, :first_name, :last_name, :email])
    |> Map.put(:token, token)
  end
end
