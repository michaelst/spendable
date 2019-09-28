defmodule Budget.User.Resolver do
  def create(params, _context) do
    struct(Budget.User)
    |> Budget.User.changeset(params)
    |> Budget.Repo.insert()
    |> case do
      {:ok, user} ->
        {:ok, token, _claims} = Budget.Guardian.encode_and_sign(user)
        {:ok, Map.put(user, :token, token)}

      result ->
        result
    end
  end
end
