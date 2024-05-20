defmodule SpendableWeb.PageController do
  use SpendableWeb, :controller

  def privacy_policy(conn, _params) do
    render(conn, :privacy_policy, layout: false)
  end
end
