defmodule Budget.Controllers.UserController do
  use BudgetWeb, :controller

  def create(conn, params) do
    struct(Budget.User)
    |> Budget.User.changeset(params)
    |> Budget.Repo.insert()
    |> case do
      {:ok, user} ->
        conn
        |> put_view(Budget.UserView)
        |> render(:show, user)

      {:error, changeset} ->
        conn
        |> put_view(BudgetWeb.ErrorView)
        |> put_status(422)
        |> render("422.json", changeset)
    end
  end
end
