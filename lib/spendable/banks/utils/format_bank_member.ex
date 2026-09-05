defmodule Spendable.Banks.Utils.FormatBankMember do
  @moduledoc "Import this module rather than aliasing it."

  alias Spendable.Banks.Clients.Plaid

  @doc """
  Turns a Plaid item into bank member attributes, fetching the institution for its name and logo.

  Shared by the first connection and every later sync, so a renamed or errored institution is
  picked up either way. No error code means the connection is healthy.
  """
  def format_bank_member(%{"item" => details}) do
    {name, logo} = institution_details(details["institution_id"])

    %{
      external_id: details["item_id"],
      institution_id: details["institution_id"],
      logo: logo,
      name: name,
      provider: "Plaid",
      status: details["error"]["error_code"] || "CONNECTED"
    }
  end

  defp institution_details(institution_id) when is_binary(institution_id) do
    case Plaid.institution(institution_id) do
      {:ok, %{body: %{"institution" => institution}}} ->
        {institution["name"] || "Bank", institution["logo"]}

      _error ->
        {"Bank", nil}
    end
  end

  defp institution_details(_institution_id), do: {"Bank", nil}
end
