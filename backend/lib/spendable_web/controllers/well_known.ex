defmodule Spendable.Web.Controllers.WellKnown do
  use Spendable.Web, :controller

  def apple_app_site_association(conn, _params) do
    json(conn, %{
      webcredentials: %{
        apps: ["fiftysevenmedia.Spendable"]
      }
    })
  end
end
