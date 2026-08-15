defmodule Spendable.Banks.Utils.FormatBankMember do
  @moduledoc "Import this module rather than aliasing it."

  alias Spendable.Banks.Clients.Plaid

  @doc """
  Turns a Plaid item into bank member attributes, fetching the institution for its name and logo.

  Shared by the first connection and every later sync, so a renamed or errored institution is
  picked up either way. No error code means the connection is healthy.
  """
  def format_bank_member(%{"item" => details}) do
    {:ok, %{body: %{"institution" => %{"name" => name, "logo" => logo}}}} =
      Plaid.institution(details["institution_id"])

    %{
      external_id: details["item_id"],
      institution_id: details["institution_id"],
      logo: logo,
      name: name,
      provider: "Plaid",
      status: details["error"]["error_code"] || "CONNECTED"
    }
  end
end
