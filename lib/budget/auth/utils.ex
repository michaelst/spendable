defmodule Budget.Auth.Utils do
  def authenticate(params) do
    with user when not is_nil(user) <- Budget.Repo.get_by(Budget.User, email: String.downcase(params.email)),
         true <- Bcrypt.verify_pass(params.password, user.password) do
      {:ok, user}
    else
      _ -> {:error, "Incorrect login credentials"}
    end
  end
end
