defmodule SpendableWeb.Live.UserAuth do
  use SpendableWeb, :verified_routes

  import Phoenix.Component
  import Phoenix.LiveView

  alias Spendable.Accounts
  alias Spendable.Scope

  def on_mount(:ensure_authenticated, _params, %{"current_user_id" => id}, socket) do
    case Accounts.get_user(id) do
      {:ok, user} -> {:cont, assign(socket, :current_scope, Scope.for_user(user))}
      {:error, :user_not_found} -> {:halt, redirect(socket, to: ~p"/")}
    end
  end

  def on_mount(:ensure_authenticated, _params, _session, socket) do
    {:halt, redirect(socket, to: ~p"/")}
  end
end
