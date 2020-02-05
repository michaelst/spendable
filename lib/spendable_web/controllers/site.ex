defmodule Spendable.Web.Controllers.Site do
  use Spendable.Web, :controller

  def privacy_policy(conn, _) do
    conn
    |> put_layout(false)
    |> render("privacy-policy.html")
  end

  def contact_us(conn, _) do
    conn
    |> put_layout(false)
    |> render("contact_us.html")
  end
end
