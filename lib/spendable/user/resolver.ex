defmodule Spendable.User.Resolver do
  alias Spendable.Guardian
  alias Spendable.Repo
  alias Spendable.User

  def current_user(_params, %{context: %{current_user: user}}) do
    {:ok, user}
  end

  def create(params, _context) do
    struct(User)
    |> User.changeset(params)
    |> Repo.insert()
    |> case do
      {:ok, user} ->
        {:ok, token, _claims} = Guardian.encode_and_sign(user)
        {:ok, Map.put(user, :token, token)}

      result ->
        result
    end
  end

  def update(params, %{context: %{current_user: user}}) do
    user
    |> User.changeset(params)
    |> Repo.update()
  end
end
