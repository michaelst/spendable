defmodule SpendableWeb.Live.Budgets do
  use SpendableWeb, :live_view

  import SpendableWeb.Utils.BudgetCard

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
              :if={not is_nil(@changeset)}
              type="button"
              phx-click={JS.push("close") |> hide_details()}
              class="text-sm font-semibold leading-6 text-blue-400"
            >
              Close
            </button>
          </div>
        </header>
        <!-- Month summary -->
        <div class="flex flex-wrap items-end justify-between gap-6 border-b border-white/5 px-8 py-6">
          <div :if={@current_month_is_selected}>
            <p class="text-xs font-semibold uppercase tracking-wide text-gray-400">Spendable</p>
            <p class={[
              "mt-1 text-4xl font-semibold",
              if(Decimal.negative?(@spendable), do: "text-red-400", else: "text-green-400")
            ]}>
              {Utils.format_currency(@spendable)}
            </p>
          </div>
          <div class="ml-auto flex items-end gap-x-10 text-right">
            <!-- Earned beside Funded is the check the whole method rests on: budgets that promise
            more each month than the month brings in are the thing worth noticing. -->
            <div>
              <p class="text-2xl font-semibold text-white">{Utils.format_currency(@earned_total)}</p>
              <p class="text-xs uppercase tracking-wide text-gray-400">Earned</p>
            </div>
            <div :if={@current_month_is_selected}>
              <p class="text-2xl font-semibold text-white">{Utils.format_currency(@funded_total)}</p>
              <p class="text-xs uppercase tracking-wide text-gray-400">Funded</p>
            </div>
            <div>
              <p class="text-2xl font-semibold text-white">{Utils.format_currency(@spent_total)}</p>
              <p class="text-xs uppercase tracking-wide text-gray-400">Spent</p>
            </div>
          </div>
        </div>
        <!-- Budget cards -->
        <ul role="list" class="grid grid-cols-1 gap-4 px-8 py-6 md:grid-cols-2 xl:grid-cols-3">
          <li
            :for={card <- @cards}
            class="group rounded-xl bg-black/20 p-5 ring-1 ring-inset ring-white/5 hover:bg-white/5 hover:ring-white/10"
          >
            <div class="flex items-center justify-between gap-x-2">
              <h2 class="truncate text-sm font-semibold leading-6 text-white">{card.budget.name}</h2>
              <div class="flex flex-none items-center gap-x-2">
                <span
                  :if={card.pill}
                  class={["rounded-full py-1 px-2 text-xs font-medium ring-1 ring-inset", card.pill_class]}
                >
                  {card.pill}
                </span>
                <button
                  :if={card.editable?}
                  type="button"
                  aria-label={"Edit #{card.budget.name}"}
                  phx-click={JS.push("select_budget") |> show_details()}
                  phx-value-id={card.budget.id}
                  class="cursor-pointer text-gray-400 hover:text-blue-400"
                >
                  <.icon name="pi-pencil-simple" class="size-4" />
                </button>
              </div>
            </div>
            <!-- What the figure is stands under it rather than beside it, so the eye reads the
            number first and the word only if it needs to. -->
            <div class="mt-4">
              <p class={[
                "text-3xl font-semibold",
                amount_class(card)
              ]}>
                {Utils.format_currency(card.amount)}
              </p>
              <p class="text-xs uppercase tracking-wide text-gray-400">{card.label}</p>
            </div>
            <div :if={card.percent} class="mt-4 h-1 w-full rounded-full bg-white/10">
              <div class={["h-1 rounded-full", bar_class(card.bar)]} style={"width: #{card.percent}%"} />
            </div>
            <p class="mt-3 text-xs text-gray-400">{card.footer}</p>
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
              options={[
                {"Envelope", :envelope},
                {"Goal", :goal},
                {"Income", :income},
                {"Track Spending Only", :tracking}
              ]}
            />
            <.input type="text" label={amount_label(f[:type].value)} field={f[:budgeted_amount]} />
            <!-- An envelope is asked whether it funds itself, not how much: the amount it funds
            is the amount it is budgeted, and two numbers that are always equal read as a bug. -->
            <!-- Its own amount rather than a switch tied to the budgeted one: a user can measure
            spending against 400 while only being able to put 300 in. Blank means it does not fund
            itself and the user fills it. -->
            <.input
              :if={f[:type].value == :envelope}
              type="text"
              label="Fund Each Month"
              field={f[:funding_amount]}
            />
            <!-- Off means the month tops the envelope back up to its amount, so an overspend does
            not follow it into the next month and leftover does not pile up. -->
            <.input
              :if={f[:type].value == :envelope}
              type="checkbox"
              label="Carry the balance into next month"
              field={f[:rollover]}
            />
            <.input
              :if={f[:type].value == :goal}
              type="text"
              label="Monthly Contribution"
              field={f[:funding_amount]}
            />
            <.input
              :if={f[:type].value in [:envelope, :goal]}
              type="text"
              label="Allocated"
              field={f[:balance]}
            />
            <button
              :if={@changeset.data.id}
              id="archive"
              type="button"
              phx-click={JS.push("archive") |> hide_details()}
              class="cursor-pointer text-sm font-semibold leading-6 text-red-400 hover:text-red-300"
            >
              Archive budget
            </button>
          </div>
        </.simple_form>
        <!-- Deviating for one month is its own act: it moves money into the budget rather than
        changing what every month puts in, so it is a separate form writing a separate record. -->
        <form
          :if={fundable?(@changeset, @current_month_is_selected)}
          id="funding-form"
          phx-change="fund_change"
          phx-submit="fund"
          class="space-y-6 border-t border-white/5 m-6 pt-6"
        >
          <.input
            type="text"
            label="Funded This Month"
            name="funding[amount]"
            value={@funded_this_month}
          />
          <button
            id="fund"
            type="submit"
            class="cursor-pointer text-sm font-semibold leading-6 text-blue-400 hover:text-blue-300"
          >
            Fund this month
          </button>
        </form>
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

    funded = Map.get(socket.assigns.funded, budget.id, Decimal.new("0.00"))

    socket
    |> assign(:changeset, Budget.changeset(budget, %{}))
    |> assign(:funded_this_month, Decimal.to_string(funded))
    |> noreply()
  end

  # Holds what was typed, so the figure does not snap back to what the month already funded.
  def handle_event("fund_change", %{"funding" => %{"amount" => amount}}, socket) do
    {:noreply, assign(socket, :funded_this_month, amount)}
  end

  def handle_event("fund", %{"funding" => %{"amount" => amount}}, socket) do
    scope = socket.assigns.current_scope
    budget = socket.assigns.changeset.data

    case Budgets.update_funding(scope, budget, socket.assigns.selected_month, amount) do
      {:ok, _funding} -> socket |> fetch_data() |> noreply()
      {:error, _changeset} -> socket |> assign(:funded_this_month, amount) |> noreply()
    end
  end

  def handle_event("archive", _params, socket) do
    {:ok, _budget} = Budgets.archive_budget(socket.assigns.current_scope, socket.assigns.changeset.data)

    socket |> fetch_data() |> noreply()
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
    selected_month = socket.assigns[:selected_month] || Date.beginning_of_month(Date.utc_today())
    summary = Budgets.calculate_month_summary(scope, selected_month, search: socket.assigns[:search])
    listed = listed_budgets(summary.budgets, scope, summary.current_month)

    socket
    |> assign(:spendable, summary.spendable)
    |> assign(:spent, summary.spent)
    |> assign(:spent_by_month, summary.spent_by_month)
    |> assign(:selected_month, selected_month)
    |> assign(:budgets, listed)
    |> assign(:funded, summary.funded)
    |> assign(:funded_this_month, "0.00")
    |> assign(:cards, build_cards(listed, summary, summary.current_month))
    |> assign(:funded_total, summary.funded_total)
    |> assign(:earned_total, summary.earned_total)
    |> assign(:spent_total, summary.spent_total)
    |> assign(:current_month_is_selected, summary.current_month)
    |> assign(:changeset, nil)
  end

  # A past month has no Spendable figure above the list, so the budget is the only place left to
  # read what came out of it.
  defp listed_budgets(budgets, _scope, false = _current_month_is_selected), do: by_type(budgets)

  defp listed_budgets([], _scope, _current_month_is_selected), do: []

  # Card debt is not a budget, but it reads as one on this page: a negative balance to cover, and
  # no id because there is no row behind it. Spendable is the figure the page opens with, so
  # listing it again only says the same word twice about two different numbers.
  defp listed_budgets(budgets, scope, _current_month_is_selected) do
    credit_cards = %Budget{
      name: "Credit Cards",
      type: :envelope,
      balance: scope |> Banks.calculate_credit_card_balance() |> Decimal.negate()
    }

    [credit_cards | budgets |> Enum.reject(&(&1.name == "Spendable")) |> by_type()]
  end

  # Envelopes, then what is only tracked, alphabetical inside each. Grouping them by what they are
  # does the work a heading over each group would, without the headings. Income and goals go last:
  # both are money going in rather than out, so neither is what the month is about.
  defp by_type(budgets), do: Enum.sort_by(budgets, &{type_order(&1.type), &1.name})

  defp type_order(:envelope), do: 0
  defp type_order(:tracking), do: 1
  defp type_order(:income), do: 2
  defp type_order(:goal), do: 3

  defp build_cards(budgets, summary, current_month_is_selected) do
    Enum.map(budgets, fn budget ->
      month = %{
        spent: figure(summary.spent, budget.id),
        received: figure(summary.received, budget.id),
        funded: figure(summary.funded, budget.id)
      }

      credit_cards? = is_nil(budget.id)
      card = build_budget_card(budget, month, current_month_is_selected)

      # Card debt is not an envelope with something left in it, it is what is owed right now, and
      # the pill calling it one is only there to satisfy the card it is built from.
      Map.merge(card, %{
        budget: budget,
        amount: if(credit_cards?, do: budget.balance, else: card.amount),
        label: if(credit_cards?, do: "BALANCE", else: card.label),
        pill: if(credit_cards?, do: nil, else: pill(budget.type)),
        pill_class: pill_class(budget.type),
        editable?: not credit_cards? and budget.name != "Spendable"
      })
    end)
  end

  # Only reached when there is a percent to draw, and a card has a bar exactly when it has one.
  # The synthetic Credit Cards row has no id, so it is in none of the month's maps.
  defp figure(figures, budget_id), do: Map.get(figures, budget_id, Decimal.new("0.00"))

  # Only a saved budget that holds money can have a month's funding edited, and only the month the
  # user is actually looking at.
  defp fundable?(%{data: %{id: id, type: type}}, true = _current_month_is_selected)
       when is_binary(id),
       do: type in [:envelope, :goal]

  defp fundable?(_changeset, _current_month_is_selected), do: false

  # An overspend reads as a positive figure, so the label is what says it is bad rather than a
  # minus sign.
  defp amount_class(%{label: "OVERSPENT"}), do: "text-red-400"

  defp amount_class(%{amount: amount}) do
    if Decimal.negative?(amount), do: "text-red-400", else: "text-white"
  end

  defp amount_label(:goal), do: "Goal Amount"
  defp amount_label(:income), do: "Expected Each Month"
  defp amount_label(:tracking), do: "Monthly Limit"
  defp amount_label(_envelope), do: "Budgeted Amount"

  defp bar_class("over"), do: "bg-red-500"
  defp bar_class("under"), do: "bg-blue-500"
  defp bar_class("goal"), do: "bg-green-500"
  defp bar_class("income"), do: "bg-emerald-400"

  defp pill(:tracking), do: "Tracking"
  defp pill(:envelope), do: "Envelope"
  defp pill(:goal), do: "Goal"
  defp pill(:income), do: "Income"

  defp pill_class(:tracking), do: "text-gray-400 bg-gray-400/10 ring-gray-400/20 group-hover:ring-gray-400/50"
  defp pill_class(:envelope), do: "text-blue-400 bg-blue-400/10 ring-blue-400/20 group-hover:ring-blue-400/50"
  defp pill_class(:goal), do: "text-green-400 bg-green-400/10 ring-green-400/20 group-hover:ring-green-400/50"

  defp pill_class(:income),
    do: "text-emerald-400 bg-emerald-400/10 ring-emerald-400/20 group-hover:ring-emerald-400/50"
end
