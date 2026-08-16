defmodule SpendableWeb.BankLogoController do
  use SpendableWeb, :controller

  import SpendableWeb.Utils.SendLogo

  alias Spendable.Accounts
  alias Spendable.Banks
  alias Spendable.Scope

  def show(conn, %{"id" => id}) do
    with {:ok, user} <- Accounts.get_user(get_session(conn, :current_user_id)),
         {:ok, bank_member} <- Banks.get_bank_member(Scope.for_user(user), id: id),
         {:ok, logo} <- decode_logo(bank_member.logo) do
      send_logo(conn, logo)
    else
      _no_logo -> send_resp(conn, 404, "")
    end
  end
end
