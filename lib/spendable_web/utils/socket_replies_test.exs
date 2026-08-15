defmodule SpendableWeb.Utils.SocketRepliesTest do
  use ExUnit.Case, async: true

  import SpendableWeb.Utils.SocketReplies

  test "wraps a socket for each lifecycle return" do
    assert {:noreply, :socket} = noreply(:socket)
    assert {:ok, :socket} = ok(:socket)
    assert {:cont, :socket} = cont(:socket)
  end
end
