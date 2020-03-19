defmodule Spendable.Web.Controllers.Plaid do
  use Spendable.Web, :controller

  alias Spendable.Repo

  def webhook(conn, %{"item_id" => item_id}) when is_binary(item_id) do
    case Repo.get_by(Spendable.Banks.Member, external_id: item_id) do
      nil ->
        send_resp(conn, :not_found, "")

      member ->
        {:ok, _} = Exq.enqueue(Exq, "default", Spendable.Jobs.Banks.SyncMember, [member.id])

        send_resp(conn, :ok, "")
    end
  end

  def webhook(conn, _params), do: send_resp(conn, :not_found, "")
end
