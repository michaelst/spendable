defmodule Spendable.Web.Controllers.Plaid do
  use Spendable.Web, :controller

  alias Spendable.Api
  alias Spendable.Publishers.SyncMemberRequest

  def webhook(conn, %{"item_id" => item_id}) when is_binary(item_id) do
    case Api.get(Spendable.BankMember, external_id: item_id) do
      {:ok, bank_member} ->
        {:ok, %{status: 200}} = SyncMemberRequest.publish(bank_member.id)

        send_resp(conn, :ok, "")

      {:error, %Ash.Error.Query.NotFound{}} ->
        send_resp(conn, :not_found, "")
    end
  end

  def webhook(conn, _params), do: send_resp(conn, :not_found, "")
end
