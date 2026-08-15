defmodule SpendableWeb.Live.Nav do
  import Phoenix.Component
  import Phoenix.LiveView
  import SpendableWeb.Utils.SocketReplies

  def on_mount(:default, _params, _session, socket) do
    socket
    |> attach_hook(:active_tab, :handle_params, &set_active_tab/3)
    |> cont()
  end

  defp set_active_tab(_params, _url, socket) do
    active_tab =
      case socket.view do
        SpendableWeb.Live.Budgets -> :budgets
        SpendableWeb.Live.Transactions -> :transactions
        SpendableWeb.Live.Templates -> :templates
        SpendableWeb.Live.Banks -> :banks
        _other_view -> nil
      end

    socket |> assign(:active_tab, active_tab) |> cont()
  end
end
