defmodule SpendableWeb.Live.Settings do
  use SpendableWeb, :live_view

  alias Spendable.OAuth

  def mount(_params, _session, socket) do
    socket
    |> assign(:mcp_url, "#{Application.get_env(:spendable, :issuer)}/mcp")
    |> assign(:revoking, nil)
    |> fetch_authorizations()
    |> ok()
  end

  def handle_params(_params, _uri, socket), do: noreply(socket)

  def render(assigns) do
    ~H"""
    <div>
      <main id="settings">
        <header class="flex items-center justify-between border-b border-white/5 px-4 py-4 sm:px-6 sm:py-6 lg:px-8">
          <h1 class="text-base font-semibold leading-7 text-white">Settings</h1>
        </header>

        <section class="border-b border-white/5 px-4 py-6 sm:px-6 lg:px-8">
          <h2 class="text-sm font-semibold leading-6 text-white">Connect an AI assistant</h2>
          <p class="mt-1 text-sm leading-6 text-gray-400">
            Add this address to an MCP client such as Claude. You will be asked to sign in and
            approve it, and it can then do only what you can do here.
          </p>
          <code
            id="mcp-url"
            class="mt-4 block select-all rounded-md bg-gray-800 px-3 py-2 text-sm text-sky-400"
          >
            {@mcp_url}
          </code>
        </section>

        <section class="px-4 py-6 sm:px-6 lg:px-8">
          <h2 class="text-sm font-semibold leading-6 text-white">Connected apps</h2>

          <p :if={@authorizations == []} class="mt-1 text-sm leading-6 text-gray-400">
            Nothing is connected yet.
          </p>

          <ul role="list" class="divide-y divide-white/5">
            <li
              :for={authorization <- @authorizations}
              class="flex items-center justify-between py-4"
            >
              <div class="min-w-0">
                <h3 class="truncate text-sm font-semibold leading-6 text-white">
                  {authorization.client_name}
                </h3>
                <p class="text-xs leading-5 text-gray-400">
                  Connected {Calendar.strftime(authorization.last_authorized_at, "%B %-d, %Y")}
                </p>
              </div>
              <button
                type="button"
                id={"disconnect-#{authorization.client_id}"}
                phx-click="revoke"
                phx-value-client_id={authorization.client_id}
                class="text-sm font-semibold leading-6 text-red-400"
              >
                Disconnect
              </button>
            </li>
          </ul>
        </section>
      </main>

      <div :if={@revoking} id="confirm-disconnect" class="relative z-50">
        <div class="fixed inset-0 bg-gray-900/80"></div>
        <div class="fixed inset-0 flex items-center justify-center p-4">
          <div class="w-full max-w-sm rounded-lg bg-gray-800 p-6">
            <h2 class="text-sm font-semibold leading-6 text-white">
              Disconnect {@revoking.client_name}?
            </h2>
            <p class="mt-2 text-sm leading-6 text-gray-400">
              It stops being able to read or change anything straight away, and has to be approved
              again to come back.
            </p>
            <div class="mt-6 grid grid-cols-2 gap-4">
              <button
                type="button"
                id="cancel-disconnect"
                phx-click="cancel_revoke"
                class="rounded-md bg-gray-700 px-3 py-2 text-sm font-semibold text-white"
              >
                Cancel
              </button>
              <button
                type="button"
                id="confirm-disconnect-button"
                phx-click="confirm_revoke"
                class="rounded-md bg-red-500 px-3 py-2 text-sm font-semibold text-white"
              >
                Disconnect
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("revoke", %{"client_id" => client_id}, socket) do
    revoking = Enum.find(socket.assigns.authorizations, &(&1.client_id == client_id))

    socket |> assign(:revoking, revoking) |> noreply()
  end

  def handle_event("cancel_revoke", _params, socket) do
    socket |> assign(:revoking, nil) |> noreply()
  end

  def handle_event("confirm_revoke", _params, socket) do
    :ok = OAuth.revoke_authorization(socket.assigns.current_scope, socket.assigns.revoking.client_id)

    socket |> assign(:revoking, nil) |> fetch_authorizations() |> noreply()
  end

  defp fetch_authorizations(socket) do
    assign(socket, :authorizations, OAuth.list_authorizations(socket.assigns.current_scope))
  end
end
