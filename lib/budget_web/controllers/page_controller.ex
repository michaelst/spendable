defmodule BudgetWeb.PageController do
  use BudgetWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
