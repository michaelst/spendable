defmodule SpendableWeb.Live.UserAuth do
  import Phoenix.Component
  import Phoenix.LiveView

  alias Spendable.User

  def on_mount(:ensure_authenticated, %{"token" => token}, _session, socket) do
    {:ok, id} = Phoenix.Token.verify(SpendableWeb.Endpoint, "user", token)

    maybe_assign_user(socket, id)
  end

  def on_mount(:ensure_authenticated, _params, %{"current_user_id" => id}, socket) do
    maybe_assign_user(socket, id)
  end

  def on_mount(:ensure_authenticated, _params, _session, socket) do
    {:halt, redirect(socket, to: "/login")}
  end

  def generate_token(user_id) do
    Phoenix.Token.sign(SpendableWeb.Endpoint, "user", user_id)
  end

  defp maybe_assign_user(socket, user_id) do
    socket =
      assign_new(socket, :current_user, fn ->
        case Spendable.Api.get(User, user_id) do
          {:ok, user} -> user
          {:error, _} -> nil
        end
      end)

    if socket.assigns.current_user do
      {:cont, socket}
    else
      {:halt, redirect(socket, to: "/login")}
    end
  end
end
