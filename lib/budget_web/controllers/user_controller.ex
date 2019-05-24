defmodule Budget.Controllers.UserController do
  use BudgetWeb, :controller

  def create(conn, params) do
    struct(Budget.User)
    |> Budget.User.changeset(params)
    |> Budget.Repo.insert()
    |> case do
      {:ok, user} -> user
      {:error, changeset} -> changeset
    end
  end
end
