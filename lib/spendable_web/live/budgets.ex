defmodule SpendableWeb.Live.Budgets do
  use SpendableWeb, :live_view

  alias Spendable.Banks
  alias Spendable.Budgets
  alias Spendable.Budgets.Schemas.Budget
  alias Spendable.Utils

  def mount(_params, _session, socket) do
    socket |> fetch_data() |> ok()
  end

  def handle_params(_params, _uri, socket) do
    noreply(socket)
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
                {Calendar.strftime(@selected_month, "%B %Y")}
                <.icon name="pi-caret-up-down" class="h-5 w-5 text-gray-500" />
              </button>
              <div
                id="month-select"
                class="hidden absolute right-0 z-10 mt-2.5 w-40 origin-top-right rounded-md bg-white max-h-96 overflow-auto shadow-lg ring-1 ring-gray-900/5 focus:outline-hidden divide-y"
                phx-click-away={JS.hide(to: "#month-select")}
              >
                <button
                  :for={month <- @spent_by_month}
                  class="block px-3 py-2 w-full text-sm leading-6 text-gray-900 flex flex-col hover:bg-gray-200"
                  phx-click={JS.push("select_month") |> JS.toggle(to: "#month-select")}
                  phx-value-month={month.month}
                >
                  <div>{Calendar.strftime(month.month, "%B %Y")}</div>
                  <div class="text-sm text-gray-400">spent: {Utils.format_currency(month.spent)}</div>
                </button>
              </div>
            </div>
            <button
              :if={is_nil(@changeset)}
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
              Archive ({length(@selected_budgets)})
            </button>
            <button
              :if={not is_nil(@changeset)}
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
                    class="rounded-sm border-white/10 bg-white/5 text-white/5"
                  />
                </div>
                <div :if={to_string(budget.id) in @selected_budgets} class="pl-1 pr-2">
                  <input
                    type="checkbox"
                    value="true"
                    checked={true}
                    phx-click="uncheck_budget"
                    phx-value-id={budget.id}
                    class="rounded-sm border-white/10 bg-white/5 text-white/5"
                  />
                </div>
                <h2 class="min-w-0 text-sm font-semibold leading-6 text-white">
                  <a href="#" class="flex gap-x-2">
                    <span class="truncate">{budget.name}</span>
                  </a>
                </h2>
              </div>
            </div>
            <div class="flex items-center">
              <div class="min-w-0 flex-auto mr-4">
                <div class="flex items-center gap-x-3">
                  <h2 class="w-full text-sm font-semibold leading-6 text-white text-right">
                    <%= if @current_month_is_selected and budget.type != :tracking do %>
                      <span class="truncate">
                        {Utils.format_currency(budget.balance)}
                        <span :if={budget.budgeted_amount}>/ {Utils.format_currency(budget.budgeted_amount)}</span>
                      </span>
                    <% else %>
                      <span class="truncate">{Utils.format_currency(@spent[budget.id])}</span>
                    <% end %>
                  </h2>
                </div>
                <div class="mt-1 gap-x-2.5 text-xs leading-5 text-gray-400 text-right uppercase">
                  <p class="truncate">{budget_subtext(budget, assigns)}</p>
                </div>
              </div>

              <div :if={@current_month_is_selected and to_string(budget.name) == "Spendable"} class="min-w-0 flex-auto mx-4">
                <div class="flex items-center gap-x-3">
                  <h2 class="w-full text-sm font-semibold leading-6 text-white text-right">
                    {Utils.format_currency(@spendable)}
                  </h2>
                </div>
                <div class="mt-1 gap-x-2.5 text-xs leading-5 text-gray-400 text-right uppercase">
                  <p class="truncate">AVAILABLE</p>
                </div>
              </div>
              <div
                :if={budget.type == :tracking}
                class="w-20 text-center rounded-full flex-none py-1 px-2 text-xs font-medium ring-1 ring-inset text-gray-400 bg-gray-400/10 ring-gray-400/20"
              >
                Tracking
              </div>
              <div
                :if={budget.type == :envelope}
                class="w-20 text-center rounded-full flex-none py-1 px-2 text-xs font-medium ring-1 ring-inset text-blue-400 bg-blue-400/10 ring-blue-400/20"
              >
                Envelope
              </div>
              <div
                :if={budget.type == :goal}
                class="w-20 text-center rounded-full flex-none py-1 px-2 text-xs font-medium ring-1 ring-inset text-green-400 bg-green-400/10 ring-green-400/20"
              >
                Goal
              </div>
              <.icon name="pi-caret-right" class="h-5 w-5 flex-none text-gray-400" />
            </div>
          </li>
        </ul>
      </main>
      <aside
        id="details-form"
        class="hidden bg-black/10 lg:fixed lg:bottom-0 lg:right-0 lg:top-16 lg:w-96 lg:overflow-y-auto lg:border-l lg:border-white/5 text-white"
      >
        <.simple_form
          :let={f}
          :if={@changeset}
          id="budget-form"
          for={@changeset}
          as={:budget}
          phx-change="validate"
          phx-submit="submit"
        >
          <header class="flex items-center justify-between border-b border-white/5 p-6">
            <h2 class="text-base font-semibold leading-7">Edit budget</h2>
            <button phx-click={hide_details()} class="text-sm font-semibold leading-6 text-blue-400">
              Save
            </button>
          </header>
          <div class="space-y-6 m-6">
            <.input type="text" label="Name" field={f[:name]} />
            <.input
              type="select"
              label="Budget Type"
              field={f[:type]}
              options={[{"Envelope", :envelope}, {"Goal", :goal}, {"Track Spending Only", :tracking}]}
            />
            <.input
              :if={f[:type].value != :tracking}
              type="text"
              label={if f[:type].value == :envelope, do: "Budgeted Amount", else: "Goal Amount"}
              field={f[:budgeted_amount]}
            />
            <.input :if={f[:type].value != :tracking} type="text" label="Allocated" field={f[:balance]} />
          </div>
        </.simple_form>
      </aside>
    </div>
    """
  end

  def handle_event("validate", %{"budget" => params}, socket) do
    changeset =
      socket.assigns.changeset.data
      |> Budget.changeset(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("submit", %{"budget" => params}, socket) do
    scope = socket.assigns.current_scope

    result =
      case socket.assigns.changeset.data do
        %Budget{id: nil} -> Budgets.create_budget(scope, params)
        budget -> Budgets.update_budget(scope, budget, params)
      end

    case result do
      {:ok, _budget} -> socket |> assign(:changeset, nil) |> fetch_data() |> noreply()
      {:error, changeset} -> socket |> assign(:changeset, changeset) |> noreply()
    end
  end

  def handle_event("search", params, socket) do
    socket
    |> assign(:search, params["search"])
    |> fetch_data()
    |> noreply()
  end

  def handle_event("close", _params, socket) do
    {:noreply, assign(socket, :changeset, nil)}
  end

  def handle_event("new", _params, socket) do
    {:noreply, assign(socket, :changeset, Budget.changeset(%Budget{}, %{}))}
  end

  def handle_event("select_month", params, socket) do
    socket
    |> assign(:selected_month, Date.from_iso8601!(params["month"]))
    |> fetch_data()
    |> noreply()
  end

  def handle_event("select_budget", params, socket) do
    budget = Enum.find(socket.assigns.budgets, &(&1.id == params["id"]))

    {:noreply, assign(socket, :changeset, Budget.changeset(budget, %{}))}
  end

  def handle_event("archive", _params, socket) do
    scope = socket.assigns.current_scope

    socket.assigns.budgets
    |> Enum.filter(&(&1.id in socket.assigns.selected_budgets))
    |> Enum.each(&Budgets.archive_budget(scope, &1))

    {:noreply, fetch_data(socket)}
  end

  def handle_event("check_budget", %{"id" => id}, socket) do
    socket
    |> assign(:selected_budgets, Enum.uniq([id | socket.assigns.selected_budgets]))
    |> noreply()
  end

  def handle_event("uncheck_budget", %{"id" => id}, socket) do
    socket
    |> assign(:selected_budgets, Enum.filter(socket.assigns.selected_budgets, &(&1 != id)))
    |> noreply()
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
    scope = socket.assigns.current_scope
    current_month = Date.beginning_of_month(Date.utc_today())
    selected_month = socket.assigns[:selected_month] || current_month
    current_month_is_selected = Date.compare(selected_month, current_month) == :eq

    budgets = Budgets.list_budgets(scope, search: socket.assigns[:search])

    socket
    |> assign(:spendable, Budgets.calculate_spendable(scope))
    |> assign(:spent, Budgets.calculate_spent(scope, budgets, selected_month))
    |> assign(:spent_by_month, Budgets.calculate_spent_by_month(scope))
    |> assign(:selected_month, selected_month)
    |> assign(:selected_budgets, [])
    |> assign(:budgets, maybe_add_credit_cards(budgets, scope, current_month_is_selected))
    |> assign(:current_month_is_selected, current_month_is_selected)
    |> assign(:changeset, nil)
  end

  # Card debt is not a budget, but it reads as one on this page: a negative balance to cover.
  # It only makes sense against the current month, since it is what is owed right now.
  defp maybe_add_credit_cards(budgets, _scope, false = _current_month_is_selected), do: budgets

  defp maybe_add_credit_cards([spendable | budgets], scope, _current_month_is_selected) do
    credit_cards = %Budget{
      name: "Credit Cards",
      type: :envelope,
      balance: scope |> Banks.calculate_credit_card_balance() |> Decimal.negate()
    }

    [spendable, credit_cards | budgets]
  end

  defp maybe_add_credit_cards([], _scope, _current_month_is_selected), do: []

  defp budget_subtext(budget, %{current_month_is_selected: current}) do
    if current and budget.type != :tracking do
      "ALLOCATED"
    else
      "SPENT"
    end
  end
end
