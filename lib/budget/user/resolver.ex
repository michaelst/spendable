defmodule Budget.User.Resolver do
  alias Budget.User
  alias Budget.Repo
  alias Budget.Guardian

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

  def update(_args, _context), do: {:error, "Forbidden"}
end
