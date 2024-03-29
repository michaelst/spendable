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
      <main id="banks">
        <header class="flex items-center justify-between border-b border-white/5 px-4 py-4 sm:px-6 sm:py-6 lg:px-8">
          <h1 class="text-base font-semibold leading-7 text-white">Banks</h1>
        </header>

        <ul role="list" class="divide-y divide-white/5">
          <li
            :for={bank_member <- @bank_members}
            phx-click={JS.push("select_bank_member") |> show_details()}
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
      <aside
        id="details-form"
        class="hidden bg-black/10 lg:fixed lg:bottom-0 lg:right-0 lg:top-16 lg:w-96 lg:overflow-y-auto lg:border-l lg:border-white/5 text-white"
      >
        <.simple_form :if={@form} for={@form} phx-change="validate" phx-submit="submit">
          <header class="flex items-center justify-between border-b border-white/5 p-6">
            <h2 class="text-base font-semibold leading-7">Edit transaction</h2>
            <button phx-click={hide_details()} class="text-sm font-semibold leading-6 text-blue-400">
              Save
            </button>
          </header>
          <div class="space-y-6 m-6">
            <.input type="text" label="Name" field={@form[:name]} />
            <.input type="text" label="Amount" field={@form[:amount]} />
            <.input type="date" label="Date" field={@form[:date]} />
            <div>
              <div class="flex justify-between mt-2">
                <button type="button" phx-click="split" class="text-sm font-semibold text-blue-400">
                  Split
                </button>
                <div class="relative">
                  <button
                    type="button"
                    class="text-sm font-semibold text-blue-400"
                    id="sort-menu-button"
                    phx-click={JS.toggle(to: "#template-options")}
                  >
                    Apply Template
                  </button>
                  <div
                    id="template-options"
                    class="hidden absolute right-0 z-10 mt-2.5 w-40 origin-top-right rounded-md bg-white max-h-96 overflow-auto shadow-lg ring-1 ring-gray-900/5 focus:outline-none divide-y"
                    phx-click-away={JS.hide(to: "#template-options")}
                  >
                    <button
                      :for={{template_name, template_id} <- @template_form_options}
                      type="button"
                      class="block px-3 py-2 w-full text-sm leading-6 text-gray-900 flex flex-col hover:bg-gray-200"
                      phx-click={JS.push("apply_template") |> JS.toggle(to: "#template-options")}
                      phx-value-template={template_id}
                    >
                      <div><%= template_name %></div>
                    </button>
                  </div>
                </div>
              </div>
            </div>
            <.input type="textarea" label="Note" field={@form[:note]} />
            <.input type="checkbox" label="Reviewed" field={@form[:reviewed]} />
          </div>
        </.simple_form>
      </aside>
    </div>
    """
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
