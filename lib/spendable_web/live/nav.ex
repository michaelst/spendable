defmodule SpendableWeb.Live.Nav do
  import Phoenix.Component
  import Phoenix.LiveView
  import SpendableWeb.Utils.SocketReplies

  def on_mount(:default, _params, _session, socket) do
    socket
    |> attach_hook(:active_tab, :handle_params, &set_active_tab/3)
    |> cont()
  end

  @tabs %{
    SpendableWeb.Live.Budgets => :budgets,
    SpendableWeb.Live.Transactions => :transactions,
    SpendableWeb.Live.Templates => :templates,
    SpendableWeb.Live.Banks => :banks
  }

  defp set_active_tab(_params, _url, socket) do
    socket |> assign(:active_tab, @tabs[socket.view]) |> cont()
  end
end
