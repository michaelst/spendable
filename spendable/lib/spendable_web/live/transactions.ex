defmodule SpendableWeb.Live.Transactions do
  use SpendableWeb, :live_view

  alias Spendable.Transaction.Storage
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
      <main id="transactions" class="lg:pr-96">
        <header class="flex items-center justify-between border-b border-white/5 px-4 py-4 sm:px-6 sm:py-6 lg:px-8">
          <h1 class="text-base font-semibold leading-7 text-white">Transactions</h1>
        </header>

        <ul role="list" class="divide-y divide-white/5">
          <li
            :for={transaction <- @transactions}
            phx-click={JS.push("select_transaction") |> show_transaction_details()}
            phx-value-id={transaction.id}
            class="relative flex flex-row items-center justify-between space-x-4 px-4 py-6 sm:px-6 lg:px-8"
          >
            <div class="min-w-0 flex-auto">
              <div class="flex items-center gap-x-3">
                <h2 class="min-w-0 text-sm font-semibold leading-6 text-white">
                  <span class="truncate"><%= transaction.name %></span>
                </h2>
              </div>
              <div class="mt-2 flex items-center gap-x-2.5 text-xs leading-5 text-gray-400">
                <p class="truncate"><%= Timex.format!(transaction.date, "{Mshort} {D}, {YYYY}") %></p>
              </div>
            </div>
            <div class="flex items-center">
              <div class="min-w-0 flex-auto mr-4">
                <div class="flex items-center gap-x-3">
                  <h2 class="w-full text-sm font-semibold leading-6 text-white text-right">
                    <span class="truncate"><%= Utils.format_currency(transaction.amount) %></span>
                  </h2>
                </div>
              </div>
              <div
                :if={transaction.reviewed}
                class="rounded-full flex-none py-1 px-2 text-xs font-medium ring-1 ring-inset text-green-400 bg-green-400/10 ring-green-400/20"
              >
                Reviewed
              </div>
              <.icon name="hero-chevron-right-mini" class="h-5 w-5 flex-none text-gray-400" />
            </div>
          </li>
        </ul>
      </main>
      <aside
        id="transaction-details"
        class="bg-black/10 lg:fixed lg:bottom-0 lg:right-0 lg:top-16 lg:w-96 lg:overflow-y-auto lg:border-l lg:border-white/5"
      >
        <header class="flex items-center justify-between border-b border-white/5 px-4 py-4 sm:px-6 sm:py-6 lg:px-8">
          <h2 class="text-base font-semibold leading-7 text-white">Edit transaction</h2>
          <button phx-click={hide_transaction_details()} class="text-sm font-semibold leading-6 text-blue-400">Save</button>
        </header>
        <.simple_form :if={@form} for={@form} phx-change="validate" phx-submit="submit" class="mx-4">
          <.input type="text" label="Name" field={@form[:name]} />
          <.input type="text" label="Amount" field={@form[:amount]} />
          <.input type="date" label="Date" field={@form[:date]} />
          <.input type="textarea" label="Note" field={@form[:note]} />
          <.input type="checkbox" label="Reviewed" field={@form[:reviewed]} />
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
      {:ok, _transaction} -> {:noreply, socket |> assign(:form, nil)}
      {:error, form} -> {:noreply, assign(socket, form: form)}
    end
  end

  def handle_event("search", params, socket) do
    {:noreply,
     socket
     |> assign(:search, params["search"])
     |> fetch_data()}
  end

  def handle_event("select_transaction", params, socket) do
    transaction = Enum.find(socket.assigns.transactions, &(to_string(&1.id) == params["id"]))

    form =
      transaction
      |> AshPhoenix.Form.for_update(:update,
        api: QueryDesk.Api,
        forms: [auto?: true]
      )
      |> to_form()

    {:noreply,
     socket
     |> assign(:form, form)}
  end

  def show_transaction_details(js \\ %JS{}) do
    js
    |> JS.show(to: "#transaction-details", transition: "fade-in")
    |> JS.add_class(
      "lg:pr-96",
      to: "#transactions"
    )
  end

  def hide_transaction_details(js \\ %JS{}) do
    js
    |> JS.hide(to: "#transaction-details", transition: "fade-out")
    |> JS.remove_class(
      "lg:pr-96",
      to: "#transactions",
      transition: "fade-out"
    )
  end

  defp fetch_data(socket) do
    transactions =
      Storage.list_transactions(socket.assigns.current_user.id,
        search: socket.assigns[:search]
      )

    id = "235063"

    transaction = Enum.find(transactions, &(to_string(&1.id) == id))

    form =
      transaction
      |> AshPhoenix.Form.for_update(:update,
        api: QueryDesk.Api,
        forms: [auto?: true]
      )
      |> to_form()

    socket
    |> assign(:transactions, transactions)
    |> assign(:form, form)
  end
end
