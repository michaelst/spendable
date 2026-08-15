defmodule SpendableWeb.PlaidController do
  use SpendableWeb, :controller

  alias Spendable.Banks

  def webhook(conn, %{"item_id" => item_id}) when is_binary(item_id) do
    case Banks.get_bank_member_by_external_id(item_id) do
      {:ok, bank_member} ->
        {:ok, _job} = Banks.queue_sync(bank_member)

        send_resp(conn, :ok, "")

      {:error, :bank_member_not_found} ->
        send_resp(conn, :not_found, "")
    end
  end

  def webhook(conn, _params), do: send_resp(conn, :not_found, "")
end
