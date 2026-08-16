defmodule SpendableWeb.Live.OAuthAuthorize do
  use SpendableWeb, :live_view

  alias Spendable.OAuth

  # What approving actually hands over, in the order it matters.
  @permissions [
    %{
      icon: "pi-money",
      title: "Read your budgets and balances",
      detail: "Names, what each one holds, and what it is meant to hold."
    },
    %{
      icon: "pi-credit-card",
      title: "Read your transactions",
      detail: "Name, amount, date, note, and the budgets they are divided across."
    },
    %{
      icon: "pi-copy",
      title: "Change budgets, splits and allocations",
      detail: "Create and rename them, and decide how a transaction is divided."
    }
  ]

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Authorize")
      |> assign(:permissions, @permissions)
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
    <.auth_backdrop />
    <div class="px-4 py-10 sm:px-6 sm:py-28 lg:px-8 xl:px-28 xl:py-32 bg-white min-h-screen">
      <div class="mx-auto max-w-xl lg:mx-0">
        <img class="h-12" src={~p"/images/full-logo.svg"} alt="Spendable" />

        <h1 class="mt-8 text-3xl font-bold tracking-tight text-zinc-900">
          This app could not be verified
        </h1>
        <p class="text-base/7 mt-4 text-zinc-600">{@message}</p>

        <.link navigate={~p"/budgets"} class="mt-8 inline-block text-sm font-semibold text-brand">
          Go to Spendable
        </.link>
      </div>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <.auth_backdrop />
    <div class="px-4 py-10 sm:px-6 sm:py-12 lg:px-8 xl:px-28 xl:py-14 bg-white min-h-screen">
      <div class="mx-auto max-w-xl lg:mx-0">
        <img class="h-12" src={~p"/images/full-logo.svg"} alt="Spendable" />

        <h1 class="mt-8 text-3xl font-bold tracking-tight text-zinc-900">
          {@request.client.client_name} wants access to your Spendable account
        </h1>

        <dl class="mt-8 divide-y divide-zinc-200 border-y border-zinc-200">
          <.permission
            :for={permission <- @permissions}
            icon={permission.icon}
            title={permission.title}
            detail={permission.detail}
          />
        </dl>

        <p class="mt-8 text-xs font-semibold uppercase tracking-wider text-zinc-500">Redirects to</p>
        <p class="mt-2 flex items-center gap-x-2 text-zinc-900">
          <.icon name="pi-caret-right" class="h-4 w-4 shrink-0 text-zinc-400" />
          <span class="break-all font-mono text-sm">{@request.redirect_uri}</span>
        </p>

        <div class="mt-8 flex items-center gap-x-6">
          <button
            id="approve"
            type="button"
            phx-click="approve"
            class="rounded-lg bg-zinc-900 px-5 py-3 text-sm font-semibold text-white hover:bg-zinc-700"
          >
            Allow access
          </button>
          <button id="deny" type="button" phx-click="deny" class="text-sm font-semibold text-brand">
            Deny
          </button>
        </div>

        <p class="text-sm/6 mt-8 text-zinc-500">
          {@request.client.client_name} is not operated by Spendable. You can revoke this access at any
          time. Spendable is open source - you can read exactly what it does at <a
            href="https://github.com/michaelst/spendable"
            target="_blank"
            class="text-brand"
          >
            github.com/michaelst/spendable</a>.
        </p>
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

  attr :icon, :string, required: true
  attr :title, :string, required: true
  attr :detail, :string, required: true

  defp permission(assigns) do
    ~H"""
    <div class="flex items-start gap-x-4 py-5">
      <.icon name={@icon} class="h-6 w-6 mt-0.5 shrink-0 text-zinc-400" />
      <div>
        <dt class="text-base font-semibold text-zinc-900">{@title}</dt>
        <dd class="mt-1 text-sm text-zinc-600">{@detail}</dd>
      </div>
    </div>
    """
  end

  defp message(:missing_client_id), do: "The request did not say which app is asking for access."
  defp message(:unknown_client), do: "The app asking for access is not registered with Spendable."
  defp message(:missing_redirect_uri), do: "The request did not say where to send you afterwards."

  defp message(:invalid_redirect_uri) do
    "The address this request wants to send you back to is not one the app registered."
  end
end
