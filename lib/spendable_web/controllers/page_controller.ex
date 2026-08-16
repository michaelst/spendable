defmodule SpendableWeb.PageController do
  use SpendableWeb, :controller

  def privacy_policy(conn, _params) do
    render(conn, :privacy_policy, layout: false)
  end

  @doc """
  Where a bank's OAuth page returns to. The iOS app claims this path as a universal link and
  never lets the request reach us, so anything rendered here is what someone sees when they
  opened the link without the app - a stale tab left over from the flow, most often.
  """
  def plaid_oauth(conn, _params) do
    render(conn, :plaid_oauth, layout: false)
  end
end
