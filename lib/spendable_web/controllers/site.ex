defmodule Spendable.Web.Controllers.Site do
  use Spendable.Web, :controller

  def index(conn, params) do
    position =
      if params["email"] do
        Spendable.Repo.insert_all(
          "waitlist",
          [
            %{email: params["email"]}
          ],
          on_conflict: {:replace, [:email]},
          conflict_target: [:email],
          returning: [:id]
        )
        |> case do
          {1, [%{id: id}]} -> id
          _ -> nil
        end
      end

    conn
    |> put_layout(false)
    |> render("index.html", position: position)
  end

  def privacy_policy(conn, _) do
    render(conn, "privacy-policy.html")
  end

  def contact_us(conn, _) do
    render(conn, "contact_us.html")
  end
end
