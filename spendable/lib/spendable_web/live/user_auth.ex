defmodule SpendableWeb.Live.UserAuth do
  import Phoenix.Component
  import Phoenix.LiveView

  alias Spendable.User

  def on_mount(:ensure_authenticated, _params, %{"current_user_id" => id}, socket) do
    socket =
      socket
      |> assign_new(:current_user, fn ->
        case Spendable.Api.get(User, id) do
          {:ok, user} -> user
          {:error, _} -> nil
        end
      end)

    if socket.assigns.current_user do
      {:cont, socket}
    else
      {:halt, redirect(socket, to: "/")}
    end
  end

  def on_mount(:ensure_authenticated, _params, _session, socket) do
    {:halt, redirect(socket, to: "/")}
  end
end
