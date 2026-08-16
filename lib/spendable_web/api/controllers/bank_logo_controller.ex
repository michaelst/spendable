defmodule SpendableWeb.Api.BankLogoController do
  use SpendableWeb, :api_controller

  import SpendableWeb.Utils.SendLogo

  alias OpenApiSpex.Schema
  alias Spendable.Banks
  alias SpendableWeb.Api.Schemas.Errors

  tags ["banks"]

  operation :show,
    summary: "An institution's logo",
    description: "Cacheable and ETagged, so a client can hold it on disk and revalidate for free.",
    parameters: [id: [in: :path, type: :string, required: true]],
    responses: [
      ok: {"PNG", "image/png", %Schema{type: :string, format: :binary}},
      not_found: {"Errors", "application/json", Errors}
    ]

  def show(conn, %{"id" => id}) do
    with {:ok, bank_member} <- Banks.get_bank_member(conn.assigns.current_scope, id: id),
         {:ok, logo} <- decode_logo(bank_member.logo) do
      send_logo(conn, logo)
    else
      _no_logo -> send_resp(conn, 404, "")
    end
  end
end
