defmodule SpendableWeb.Live.Transactions do
  use SpendableWeb, :live_view

  alias Spendable.Transaction
  alias Spendable.Utils

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page: 1, per_page: 25)}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket |> fetch_data()}
  end

  def render(assigns) do
    ~H"""
    <div>
      <main id="transactions" phx-click={hide_details()}>
        <header class="flex items-center justify-between border-b border-white/5 px-8 py-6">
          <h1 class="text-base font-semibold leading-7 text-white">Transactions</h1>
          <div class="flex gap-x-6">
            <button
              :if={not Enum.empty?(@selected_transactions)}
              id="delete"
              type="button"
              phx-click="delete"
              class="text-sm font-semibold leading-6 text-blue-400"
            >
              Delete (<%= length(@selected_transactions) %>)
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

        <ul
          id="transactions-list"
          phx-update="stream"
          phx-viewport-top={@page > 1 && "prev-page"}
          phx-viewport-bottom={!@end_of_timeline? && "next-page"}
          phx-page-loading
          class={[
            "divide-y divide-white/5",
            if(@end_of_timeline?, do: "pb-10", else: "pb-[calc(200vh)]"),
            if(@page == 1, do: "", else: "pt-[calc(200vh)]")
          ]}
        >
          <li
            :for={{id, transaction} <- @streams.transactions}
            id={id}
            phx-click={JS.push("select_transaction") |> show_details()}
            phx-value-id={transaction.id}
            class="relative flex flex-row items-center justify-between space-x-4 py-6 pr-8"
          >
            <div class="min-w-0 flex-auto ml-1">
              <div class="flex items-center">
                <div class="pl-1 pr-2">
                  <input
                    type="checkbox"
                    value={transaction.id in @selected_transactions}
                    phx-click="toggle_select_transaction"
                    phx-value-id={transaction.id}
                    class="rounded border-white/10 bg-white/5 text-white/5 opacity-0 hover:opacity-100 checked:opacity-100"
                  />
                </div>
                <div>
                  <h2 class="min-w-0 text-sm font-semibold leading-6 text-white">
                    <span class="truncate"><%= transaction.name %></span>
                  </h2>
                  <div class="mt-2 flex items-center gap-x-2.5 text-xs leading-5 text-gray-400">
                    <p class="truncate"><%= Timex.format!(transaction.date, "{Mshort} {D}, {YYYY}") %></p>
                  </div>
                </div>
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
              <%= if length(@form.source.forms[:budget_allocations]) <= 1 do %>
                <.inputs_for :let={allocation_form} field={@form[:budget_allocations]}>
                  <.input
                    type="select"
                    label={if Decimal.negative?(@form[:amount].value), do: "Spend from", else: "Add to"}
                    field={allocation_form[:budget_id]}
                    options={@budget_form_options}
                  />
                </.inputs_for>
              <% else %>
                <div class="grid grid-cols-10">
                  <div class="col-span-6">
                    <%= if Decimal.negative?(@form[:amount].value), do: "Spend from", else: "Add to" %>
                  </div>
                  <div class="col-span-3">
                    Amount
                  </div>
                </div>
                <.inputs_for :let={allocation_form} field={@form[:budget_allocations]}>
                  <div class="grid grid-cols-10 items-center">
                    <div class="col-span-6 pr-2">
                      <.input type="select" field={allocation_form[:budget_id]} options={@budget_form_options} />
                    </div>
                    <div class="col-span-3">
                      <.input type="text" field={allocation_form[:amount]} />
                    </div>
                    <button
                      type="button"
                      class="cursor-pointer text-right mt-1"
                      phx-click="remove_allocation"
                      phx-value-path={allocation_form.name}
                    >
                      <.icon name="hero-x-circle" />
                    </button>
                  </div>
                </.inputs_for>
              <% end %>
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
    params =
      if Enum.count(params["budget_allocations"]) == 1 do
        %{
          params
          | "budget_allocations" => %{
              "0" => Map.put(params["budget_allocations"]["0"], "amount", params["amount"])
            }
        }
      else
        params
      end

    case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
      {:ok, transaction} ->
        {:noreply, socket |> assign(:form, nil) |> stream_insert(:transactions, transaction)}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  def handle_event("apply_template", params, socket) do
    form =
      Enum.reduce(socket.assigns.form.source.forms[:budget_allocations], socket.assigns.form, fn allocation_form, acc ->
        AshPhoenix.Form.remove_form(acc, allocation_form.name)
      end)

    form =
      Transaction.get_template(params["template"])
      |> Map.get(:budget_allocation_template_lines, [])
      |> Enum.reduce(form, fn line, acc ->
        AshPhoenix.Form.add_form(acc, [:budget_allocations], params: %{amount: line.amount, budget_id: line.budget_id})
      end)

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("split", _params, socket) do
    form = AshPhoenix.Form.add_form(socket.assigns.form, [:budget_allocations])
    {:noreply, assign(socket, form: form)}
  end

  def handle_event("remove_allocation", %{"path" => path}, socket) do
    form = AshPhoenix.Form.remove_form(socket.assigns.form, path)
    {:noreply, assign(socket, form: form)}
  end

  def handle_event("toggle_select_transaction", %{"id" => id, "value" => "on"}, socket) do
    {:noreply, assign(socket, selected_transactions: Enum.uniq([id | socket.assigns.selected_transactions]))}
  end

  def handle_event("toggle_select_transaction", %{"id" => id}, socket) do
    {:noreply, assign(socket, selected_transactions: Enum.filter(socket.assigns.selected_transactions, &(&1 != id)))}
  end

  def handle_event("delete", _params, socket) do
    socket =
      socket.assigns.selected_transactions
      |> Enum.map(&Spendable.Api.get!(Transaction, &1))
      |> Enum.reduce(socket, fn transaction, acc ->
        Spendable.Api.destroy!(transaction)
        stream_delete(acc, :transactions, transaction)
      end)

    {:noreply, fetch_data(socket)}
  end

  def handle_event("search", params, socket) do
    {:noreply,
     socket
     |> assign(search: params["search"])
     |> paginate_posts(1, true)}
  end

  def handle_event("select_transaction", params, socket) do
    transaction = Spendable.Api.get!(Transaction, params["id"], load: :budget_allocations)

    form =
      transaction
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

  def handle_event("next-page", _params, socket) do
    {:noreply, paginate_posts(socket, socket.assigns.page + 1)}
  end

  def handle_event("prev-page", %{"_overran" => true}, socket) do
    {:noreply, paginate_posts(socket, 1)}
  end

  def handle_event("prev-page", _params, socket) do
    if socket.assigns.page > 1 do
      {:noreply, paginate_posts(socket, socket.assigns.page - 1)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("close", _params, socket) do
    {:noreply, assign(socket, :form, nil)}
  end

  def show_details(js \\ %JS{}) do
    js
    |> JS.show(to: "#transaction-details", transition: "fade-in")
    |> JS.add_class(
      "lg:pr-96",
      to: "#transactions"
    )
  end

  def hide_details(js \\ %JS{}) do
    js
    |> JS.hide(to: "#transaction-details", transition: "fade-out")
    |> JS.remove_class(
      "lg:pr-96",
      to: "#transactions",
      transition: "fade-out"
    )
  end

  defp fetch_data(socket) do
    budget_form_options = Transaction.budget_form_options(socket.assigns.current_user.id)
    template_form_options = Transaction.template_form_options(socket.assigns.current_user.id)

    socket
    |> assign(
      budget_form_options: budget_form_options,
      template_form_options: template_form_options,
      selected_transactions: [],
      form: nil
    )
    |> paginate_posts(1)
  end

  defp paginate_posts(socket, new_page, reset \\ false) when new_page >= 1 do
    %{per_page: per_page, page: page} = socket.assigns

    transactions =
      Transaction.list_transactions(socket.assigns.current_user.id,
        search: socket.assigns[:search],
        page: new_page,
        per_page: per_page
      )

    {transactions, at, limit} =
      if new_page >= page do
        {transactions, -1, per_page * 3 * -1}
      else
        {Enum.reverse(transactions), 0, per_page * 3}
      end

    case transactions do
      [] ->
        assign(socket, end_of_timeline?: at == -1)

      [_ | _] = transactions ->
        socket
        |> assign(end_of_timeline?: false)
        |> assign(:page, new_page)
        |> stream(:transactions, transactions, at: at, limit: limit, reset: reset)
    end
  end
end
