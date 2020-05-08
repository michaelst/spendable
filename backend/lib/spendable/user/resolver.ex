defmodule Spendable.User.Resolver do
  alias Spendable.Guardian
  alias Spendable.Repo
  alias Spendable.User

  def current_user(_args, %{context: %{current_user: user}}) do
    {:ok, user}
  end

  def create(args, _context) do
    %User{}
    |> User.changeset(args)
    |> Repo.insert()
    |> case do
      {:ok, user} ->
        {:ok, token, _claims} = Guardian.encode_and_sign(user)
        {:ok, Map.put(user, :token, token)}

      result ->
        result
    end
  end

  def update(args, %{context: %{current_user: user}}) do
    user
    |> User.changeset(args)
    |> Repo.update()
  end
end
