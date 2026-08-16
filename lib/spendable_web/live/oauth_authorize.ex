defmodule SpendableWeb.Live.OAuthAuthorize do
  use SpendableWeb, :live_view

  alias Spendable.OAuth

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Authorize")
      |> assign(:request, nil)
      |> assign(:error, nil)

    {:ok, socket, layout: false}
  end

  def handle_params(params, _uri, socket) do
    case OAuth.validate_authorization_request(params) do
      {:ok, request} -> socket |> assign(:request, request) |> noreply()
      {:error, reason} -> socket |> assign(:error, reason) |> noreply()
      {:redirect, uri} -> socket |> redirect(external: uri) |> noreply()
    end
  end

  def render(%{request: nil} = assigns) do
    assigns = assign(assigns, :message, message(assigns.error))

    ~H"""
    <div class="flex h-screen flex-col justify-center bg-gray-900 px-6">
      <div class="w-full max-w-md mx-auto rounded-lg bg-gray-800 p-8 text-center">
        <h1 class="text-lg font-semibold text-white">This app could not be verified</h1>
        <p class="mt-2 text-sm leading-6 text-gray-400">{@message}</p>
        <.link navigate={~p"/budgets"} class="mt-6 inline-block text-sm font-semibold text-blue-400">
          Go to Spendable
        </.link>
      </div>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <div class="flex h-screen flex-col justify-center bg-gray-900 px-6">
      <div class="w-full max-w-md mx-auto rounded-lg bg-gray-800 p-8">
        <img class="h-8 mx-auto w-auto" src={~p"/images/full-logo-white.svg"} alt="Spendable" />

        <h1 class="mt-6 text-center text-lg font-semibold text-white">
          Connect {@request.client.client_name}
        </h1>

        <div class="mt-6 flex items-center gap-x-3 rounded-lg bg-gray-900 px-4 py-3">
          <img
            :if={@current_scope.user.image}
            class="h-8 w-8 rounded-full"
            src={@current_scope.user.image}
            alt=""
          />
          <p class="truncate text-sm text-gray-300">Signed in as you</p>
        </div>

        <ul class="mt-4 space-y-2 rounded-lg bg-gray-900 p-4 text-sm text-gray-300">
          <li>Read your budgets, transactions and splits</li>
          <li>Create and change budgets, splits, and how transactions are allocated</li>
          <li>Nothing it cannot already do as you, signed in</li>
        </ul>

        <p class="mt-4 text-xs text-gray-500">
          Sends you back to <span class="text-gray-400">{host(@request.redirect_uri)}</span>. You can
          disconnect it at any time from settings.
        </p>

        <div class="mt-6 grid grid-cols-2 gap-4">
          <button
            id="deny"
            type="button"
            phx-click="deny"
            class="rounded-md bg-gray-700 px-3 py-2 text-sm font-semibold text-white"
          >
            Deny
          </button>
          <button
            id="approve"
            type="button"
            phx-click="approve"
            class="rounded-md bg-blue-500 px-3 py-2 text-sm font-semibold text-white"
          >
            Connect
          </button>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("approve", _params, %{assigns: %{request: request}} = socket) do
    {:ok, _code, redirect_uri} = OAuth.create_authorization_code(socket.assigns.current_scope, request)

    socket |> redirect(external: redirect_uri) |> noreply()
  end

  def handle_event("deny", _params, %{assigns: %{request: request}} = socket) do
    socket
    |> redirect(external: OAuth.build_error_redirect(request, "access_denied"))
    |> noreply()
  end

  defp message(:missing_client_id), do: "The request did not say which app is asking for access."
  defp message(:unknown_client), do: "The app asking for access is not registered with Spendable."
  defp message(:missing_redirect_uri), do: "The request did not say where to send you afterwards."

  defp message(:invalid_redirect_uri) do
    "The address this request wants to send you back to is not one the app registered."
  end

  # A validated redirect URI always has a host, so there is no clause for one without.
  defp host(uri) do
    case URI.parse(uri) do
      %URI{host: host, port: port} when port in [nil, 80, 443] -> host
      %URI{host: host, port: port} -> "#{host}:#{port}"
    end
  end
end
