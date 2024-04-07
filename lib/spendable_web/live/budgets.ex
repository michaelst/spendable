defmodule SpendableWeb.Live.Budgets do
  use SpendableWeb, :live_view

  alias Spendable.Budget
  alias Spendable.Utils

  def mount(_params, _session, socket) do
    {:ok, fetch_data(socket)}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket |> fetch_data()}
  end

  def render(assigns) do
    ~H"""
    <div>
      <main id="budgets" phx-click={JS.push("close") |> hide_details()}>
        <header class="flex items-center justify-between border-b border-white/5 px-8 py-6">
          <h1 class="text-base font-semibold leading-7 text-white">Budgets</h1>
          <div class="flex gap-x-6">
            <!-- Sort dropdown -->
            <div class="relative">
              <button
                type="button"
                class="flex items-center gap-x-1 text-sm font-medium leading-6 text-white"
                id="sort-menu-button"
                phx-click={JS.toggle(to: "#month-select")}
              >
                <%= Timex.format!(@selected_month, "{Mfull} {YYYY}") %>
                <.icon name="hero-chevron-up-down-mini" class="h-5 w-5 text-gray-500" />
              </button>
              <div
                id="month-select"
                class="hidden absolute right-0 z-10 mt-2.5 w-40 origin-top-right rounded-md bg-white max-h-96 overflow-auto shadow-lg ring-1 ring-gray-900/5 focus:outline-none divide-y"
                phx-click-away={JS.hide(to: "#month-select")}
              >
                <button
                  :for={month <- @current_user.spent_by_month}
                  class="block px-3 py-2 w-full text-sm leading-6 text-gray-900 flex flex-col hover:bg-gray-200"
                  phx-click={JS.push("select_month") |> JS.toggle(to: "#month-select")}
                  phx-value-month={month.month}
                >
                  <div><%= Timex.format!(month.month, "{Mfull} {YYYY}") %></div>
                  <div class="text-sm text-gray-400">spent: <%= Utils.format_currency(month.spent) %></div>
                </button>
              </div>
            </div>
            <button
              :if={is_nil(@form)}
              id="new-budget"
              type="button"
              phx-click={JS.push("new") |> show_details()}
              class="text-sm font-semibold leading-6 text-blue-400"
            >
              New
            </button>
            <button
              :if={not Enum.empty?(@selected_budgets)}
              id="archive"
              type="button"
              phx-click="archive"
              class="text-sm font-semibold leading-6 text-blue-400"
            >
              Archive (<%= length(@selected_budgets) %>)
            </button>
            <button
              :if={not is_nil(@form)}
              type="button"
              phx-click={JS.push("close") |> hide_details()}
              class="text-sm font-semibold leading-6 text-blue-400"
            >
              Close
            </button>
          </div>
        </header>
        <!-- Budget list -->
        <ul role="list" class="divide-y divide-white/5">
          <li
            :for={budget <- @budgets}
            phx-click={JS.push("select_budget") |> show_details()}
            phx-value-id={budget.id}
            class="relative flex flex-row items-center justify-between space-x-4 py-6 pr-8"
          >
            <div class="min-w-0 flex-auto ml-1">
              <div class="flex items-center">
                <div :if={to_string(budget.id) not in @selected_budgets} class="pl-1 pr-2 opacity-0 hover:opacity-100">
                  <input
                    type="checkbox"
                    value="true"
                    checked={false}
                    phx-click="check_budget"
                    phx-value-id={budget.id}
                    class="rounded border-white/10 bg-white/5 text-white/5"
                  />
                </div>
                <div :if={to_string(budget.id) in @selected_budgets} class="pl-1 pr-2">
                  <input
                    type="checkbox"
                    value="true"
                    checked={true}
                    phx-click="uncheck_budget"
                    phx-value-id={budget.id}
                    class="rounded border-white/10 bg-white/5 text-white/5"
                  />
                </div>
                <h2 class="min-w-0 text-sm font-semibold leading-6 text-white">
                  <a href="#" class="flex gap-x-2">
                    <span class="truncate"><%= budget.name %></span>
                  </a>
                </h2>
              </div>
            </div>
            <div class="flex items-center">
              <div class="min-w-0 flex-auto mr-4">
                <div class="flex items-center gap-x-3">
                  <h2 class="w-full text-sm font-semibold leading-6 text-white text-right">
                    <%= if @current_month_is_selected and not budget.track_spending_only do %>
                      <span class="truncate">
                        <%= Utils.format_currency(budget.balance) %> / <%= Utils.format_currency(budget.monthly_amount) %>
                      </span>
                    <% else %>
                      <span class="truncate"><%= Utils.format_currency(budget.spent) %></span>
                    <% end %>
                  </h2>
                </div>
                <div class="mt-1 gap-x-2.5 text-xs leading-5 text-gray-400 text-right uppercase">
                  <p class="truncate"><%= budget_subtext(budget, assigns) %></p>
                </div>
              </div>
              <div
                :if={budget.track_spending_only}
                class="rounded-full flex-none py-1 px-2 text-xs font-medium ring-1 ring-inset text-gray-400 bg-gray-400/10 ring-gray-400/20"
              >
                Tracking
              </div>
              <div
                :if={not budget.track_spending_only}
                class="rounded-full flex-none py-1 px-2 text-xs font-medium ring-1 ring-inset text-blue-400 bg-blue-400/10 ring-blue-400/20"
              >
                Envelope
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
            <h2 class="text-base font-semibold leading-7">Edit budget</h2>
            <button phx-click={hide_details()} class="text-sm font-semibold leading-6 text-blue-400">
              Save
            </button>
          </header>
          <div class="space-y-6 m-6">
            <.input type="text" label="Name" field={@form[:name]} />
            <.input
              :if={not @form[:track_spending_only].value}
              type="text"
              label="Monthly Amount"
              field={@form[:monthly_amount]}
            />
            <.input :if={not @form[:track_spending_only].value} type="text" label="Allocated" field={@form[:balance]} />
            <.input type="checkbox" label="Track spending only" field={@form[:track_spending_only]} />
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
      {:ok, _budget} ->
        {:noreply, socket |> assign(:form, nil) |> fetch_data()}

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

  def handle_event("close", _params, socket) do
    {:noreply, assign(socket, :form, nil)}
  end

  def handle_event("new", _params, socket) do
    form =
      Budget
      |> AshPhoenix.Form.for_create(:create,
        api: Spendable.Api,
        actor: socket.assigns.current_user,
        forms: [auto?: true]
      )
      |> to_form()

    {:noreply, assign(socket, :form, form)}
  end

  def handle_event("select_month", params, socket) do
    {:noreply,
     socket
     |> assign(:selected_month, Timex.parse!(params["month"], "{YYYY}-{0M}-{D}"))
     |> fetch_data()}
  end

  def handle_event("select_budget", params, socket) do
    budget =
      Enum.find(socket.assigns.budgets, &(to_string(&1.id) == params["id"]))

    form =
      budget
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

  def handle_event("archive", _params, socket) do
    socket.assigns.budgets
    |> Enum.filter(&(to_string(&1.id) in socket.assigns.selected_budgets))
    |> Enum.each(&Spendable.Api.destroy!(&1, actor: socket.assigns.current_user))

    {:noreply, fetch_data(socket)}
  end

  def handle_event("check_budget", %{"id" => id}, socket) do
    {:noreply, assign(socket, selected_budgets: Enum.uniq([id | socket.assigns.selected_budgets]))}
  end

  def handle_event("uncheck_budget", %{"id" => id}, socket) do
    {:noreply, assign(socket, selected_budgets: Enum.filter(socket.assigns.selected_budgets, &(&1 != id)))}
  end

  def show_details(js \\ %JS{}) do
    js
    |> JS.show(to: "#details-form", transition: "fade-in")
    |> JS.add_class(
      "lg:pr-96",
      to: "#budgets"
    )
  end

  def hide_details(js \\ %JS{}) do
    js
    |> JS.hide(to: "#details-form", transition: "fade-out")
    |> JS.remove_class(
      "lg:pr-96",
      to: "#budgets",
      transition: "fade-out"
    )
  end

  defp fetch_data(socket) do
    current_month = Date.utc_today() |> Timex.beginning_of_month()
    selected_month = socket.assigns[:selected_month] || current_month

    budgets =
      Budget
      |> Ash.Query.for_read(:list,
        selected_month: selected_month,
        search: socket.assigns[:search]
      )
      |> Spendable.Api.read!(actor: socket.assigns.current_user)

    user = Spendable.Api.load!(socket.assigns.current_user, :spent_by_month)

    socket
    |> assign(:current_user, user)
    |> assign(:selected_month, selected_month)
    |> assign(:selected_budgets, [])
    |> assign(:budgets, budgets)
    |> assign(:current_month_is_selected, Timex.equal?(selected_month, current_month))
    |> assign(:form, nil)
  end

  defp budget_subtext(budget, %{current_month_is_selected: current}) do
    cond do
      current and to_string(budget.name) == "Spendable" -> "AVAILABLE"
      current and not budget.track_spending_only -> "ALLOCATED"
      true -> "SPENT"
    end
  end
end
