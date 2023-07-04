defmodule SpendableWeb.Live.Nav do
  import Phoenix.Component
  import Phoenix.LiveView

  def on_mount(:default, _params, _session, socket) do
    {:cont,
     socket
     |> attach_hook(:active_tab, :handle_params, &set_active_tab/3)}
  end

  defp set_active_tab(_params, _url, socket) do
    active_tab =
      case socket.view do
        SpendableWeb.Live.Budgets -> :budgets
        SpendableWeb.Live.Transactions -> :transactions
        SpendableWeb.Live.Banks -> :Banks
        _view -> nil
      end

    {:cont, assign(socket, active_tab: active_tab)}
  end
end
