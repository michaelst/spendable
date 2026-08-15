defmodule SpendableWeb.Utils.SocketReplies do
  @moduledoc "Import this module rather than aliasing it."

  @doc "Lets a handler end in a pipe instead of wrapping the whole chain in a tuple."
  def noreply(socket), do: {:noreply, socket}

  def ok(socket), do: {:ok, socket}

  def cont(socket), do: {:cont, socket}
end
