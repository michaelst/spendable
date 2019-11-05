defmodule Spendable.Web.Socket do
  use Phoenix.Socket
  use Absinthe.Phoenix.Socket, schema: Spendable.Web.Schema

  ## Channels
  # channel "room:*", ApiWeb.RoomChannel

  ## Transports
  transport(:websocket, Phoenix.Transports.WebSocket)
  # transport :longpoll, Phoenix.Transports.LongPoll

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  def connect(%{"token" => token}, socket) do
    with {:ok, decoded_token} <- Spendable.Guardian.decode_and_verify(token),
         {:ok, user} <- Spendable.Guardian.resource_from_claims(decoded_token) do
      socket =
        Absinthe.Phoenix.Socket.put_opts(socket,
          context: %{
            current_user: user
          }
        )

      {:ok, socket}
    else
      _ -> :error
    end
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     ApiWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(_socket), do: nil
end
