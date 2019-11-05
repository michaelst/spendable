defmodule Spendable.UserView do
  use Spendable.Web, :view

  def render("show.json", user) do
    {:ok, token, _claims} = Spendable.Guardian.encode_and_sign(user)

    user
    |> Map.take([:id, :first_name, :last_name, :email])
    |> Map.put(:token, token)
  end
end
