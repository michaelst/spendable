defmodule SpendableWeb.Live.Banks do
  use SpendableWeb, :live_view

  alias Spendable.BankMember

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket |> fetch_data()}
  end

  def render(assigns) do
    ~H"""
    <div>
      <main id="banks" phx-hook="Plaid">
        <header class="flex items-center justify-between border-b border-white/5 px-4 py-4 sm:px-6 sm:py-6 lg:px-8">
          <h1 class="text-base font-semibold leading-7 text-white">Banks</h1>
          <button id="open-plaid-link" phx-click="open_plaid_link" class="text-sm font-semibold leading-6 text-blue-400">
            New
          </button>
        </header>

        <ul role="list" class="divide-y divide-white/5">
          <li
            :for={bank_member <- @bank_members}
            phx-click={JS.push("select_bank_member")}
            phx-value-id={bank_member.id}
            class="relative flex flex-row items-center justify-between space-x-4 px-4 py-6 sm:px-6 lg:px-8"
          >
            <div class="min-w-0">
              <div class="flex items-center">
                <img src={"data:image/png;base64,#{bank_member.logo}"} alt="bank logo" class="h-8 mr-2" />
                <h2 class="min-w-0 text-sm font-semibold leading-6 text-white">
                  <span class="truncate"><%= bank_member.name %></span>
                </h2>
              </div>
            </div>
            <div class="flex items-center">
              <div :if={bank_member.status != "CONNECTED"} class="min-w-0 flex-auto mr-4">
                <div class="flex items-center gap-x-3">
                  <h2 class="w-full text-sm font-semibold leading-6 text-red-500 text-right">
                    <span class="truncate">
                      Reconnect <.icon name="hero-exclamation-circle" />
                    </span>
                  </h2>
                </div>
              </div>
              <.icon name="hero-chevron-right-mini" class="h-5 w-5 flex-none text-gray-400" />
            </div>
          </li>
        </ul>
      </main>
    </div>
    """
  end

  def handle_event("open_plaid_link", _params, socket) do
    case Spendable.Api.load(socket.assigns.current_user, [:plaid_link_token]) do
      {:ok, user} ->
        {:noreply, push_event(socket, "open_plaid_link", %{"link_token" => user.plaid_link_token})}

      _error ->
        {:noreply, socket}
    end
  end

  def handle_event("add_bank", %{"public_token" => public_token}, socket) do
    BankMember
    |> Ash.Changeset.for_create(:create_from_public_token, %{public_token: public_token},
      actor: socket.assigns.current_user
    )
    |> Spendable.Api.create!()

    {:noreply, push_navigate(socket, to: ~p"/banks")}
  end

  def handle_event("validate", %{"form" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.form, params)
    {:noreply, assign(socket, form: form)}
  end

  def handle_event("submit", %{"form" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
      {:ok, _bank_member} ->
        {:noreply, socket |> assign(:form, nil)}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  def handle_event("search", params, socket) do
    {:noreply,
     socket
     |> assign(:search, params["search"])
     |> fetch_data()}
  end

  def handle_event("select_bank_member", params, socket) do
    bank_member =
      Enum.find(socket.assigns.bank_members, &(to_string(&1.id) == params["id"]))

    form =
      bank_member
      |> AshPhoenix.Form.for_update(:update,
        api: Spendable.Api,
        actor: socket.assigns.current_user,
        forms: [auto?: true]
      )
      |> to_form()

    {:noreply,
     socket
     |> assign(:form, form)}
  end

  def show_details(js \\ %JS{}) do
    js
    |> JS.show(to: "#details-form", transition: "fade-in")
    |> JS.add_class(
      "lg:pr-96",
      to: "#banks"
    )
  end

  def hide_details(js \\ %JS{}) do
    js
    |> JS.hide(to: "#details-form", transition: "fade-out")
    |> JS.remove_class(
      "lg:pr-96",
      to: "#banks",
      transition: "fade-out"
    )
  end

  defp fetch_data(socket) do
    bank_members =
      BankMember.list(socket.assigns.current_user.id,
        search: socket.assigns[:search]
      )

    socket
    |> assign(:bank_members, bank_members)
    |> assign(:form, nil)
  end
end
