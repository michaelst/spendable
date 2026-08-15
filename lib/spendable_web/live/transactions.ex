defmodule SpendableWeb.Live.Transactions do
  use SpendableWeb, :live_view

  import SpendableWeb.Utils.FormOptions

  alias Spendable.Budgets
  alias Spendable.Transactions
  alias Spendable.Transactions.Schemas.Transaction
  alias Spendable.Utils

  def mount(_params, _session, socket) do
    socket
    |> assign(:page, 1)
    |> assign(:per_page, 100)
    |> assign(:show_reviewed, true)
    |> assign(:show_excluded, false)
    |> fetch_data()
    |> ok()
  end

  def handle_params(_params, _uri, socket) do
    noreply(socket)
  end

  def render(assigns) do
    ~H"""
    <div>
      <main id="transactions" phx-click={hide_details()}>
        <header class="flex items-center justify-between border-b border-white/5 px-3 py-3 sticky top-16 bg-gray-900 z-10">
          <h1 class="text-base font-semibold leading-7 text-white">Transactions</h1>
          <div class="flex gap-x-6">
            <.dropdown id="options-dropdown">
              <:trigger>
                <button class="text-sm font-semibold leading-6 text-sky-400">
                  Filter
                </button>
              </:trigger>
              <div class="absolute right-0 z-10 mt-2 w-72 origin-top-right rounded-md bg-slate-700 shadow-lg ring-1 ring-black/5 focus:outline-hidden">
                <div class="px-4 py-2 divide-y divide-white/5">
                  <div class="flex items-center justify-between py-2">
                    <span class="text-gray-300">Show reviewed transactions</span>
                    <.switch id="reviewed-option" on_toggle="change_reviewed_option" enabled={@show_reviewed} />
                  </div>
                  <div class="flex items-center justify-between py-2">
                    <span class="text-gray-300">Show excluded transactions</span>
                    <.switch id="excluded-option" on_toggle="change_excluded_option" enabled={@show_excluded} />
                  </div>
                </div>
              </div>
            </.dropdown>
            <button
              :if={not is_nil(@changeset)}
              type="button"
              phx-click={JS.push("close") |> hide_details()}
              class="text-sm font-semibold leading-6 text-sky-400"
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
            "@container divide-y divide-white/5",
            if(@end_of_timeline?, do: "pb-10", else: "pb-[calc(200vh)]"),
            if(@page == 1, do: "", else: "pt-[calc(200vh)]")
          ]}
        >
          <li
            :for={{id, transaction} <- @streams.transactions}
            id={id}
            class={[
              if(transaction.excluded or transaction.transfer_id, do: "opacity-40"),
              "group flex flex-row items-center gap-x-3 p-2"
            ]}
          >
            <input
              type="checkbox"
              checked={transaction.id in @selected_transactions}
              phx-click="toggle_select_transaction"
              phx-value-id={transaction.id}
              class="shrink-0 rounded-sm border-white/20 bg-white/5 text-sky-500 opacity-40 group-hover:opacity-100 checked:opacity-100"
            />
            <div
              id={"open-#{transaction.id}"}
              class="flex min-w-0 flex-1 basis-0 cursor-pointer items-baseline gap-x-3"
              phx-click={JS.push("select_transaction") |> show_details()}
              phx-value-id={transaction.id}
            >
              <span class="truncate text-sm font-semibold text-white">{transaction.name}</span>
              <span class="hidden shrink-0 text-xs text-gray-400 @sm:block">
                {Calendar.strftime(transaction.date, "%b %-d, %Y")}
              </span>
              <span
                :if={transaction.transfer_id}
                class="shrink-0 rounded-full bg-sky-400/10 px-2 py-0.5 text-xs font-medium text-sky-400 ring-1 ring-inset ring-sky-400/20"
              >
                Transfer
              </span>
            </div>
            <div class="hidden min-w-0 flex-1 basis-0 items-center gap-x-2 @2xl:flex">
              <img
                :if={bank_member(transaction)}
                src={~p"/banks/#{bank_member(transaction).id}/logo"}
                alt={bank_member(transaction).name}
                class="h-5 w-5 shrink-0 rounded-sm"
              />
              <span :if={bank_account(transaction)} class="truncate text-xs text-gray-400">
                {bank_account(transaction).name}
              </span>
              <span :if={bank_account(transaction)} class="shrink-0 text-xs text-gray-500">
                {mask(bank_account(transaction).number)}
              </span>
            </div>
            <span class="w-24 shrink-0 text-right text-sm font-semibold tabular-nums text-white">
              {Utils.format_currency(transaction.amount)}
            </span>
            <div class="hidden w-36 shrink-0 @lg:block">
              <form
                :if={sole_allocation(transaction)}
                id={"spend-from-#{transaction.id}"}
                phx-change="set_spend_from"
              >
                <input type="hidden" name="transaction_id" value={transaction.id} />
                <select
                  name="budget_id"
                  class="block w-full rounded-md border-0 bg-white/5 py-1 text-xs text-white ring-1 ring-inset ring-white/10 focus:ring-2 focus:ring-inset focus:ring-gray-500"
                >
                  {Phoenix.HTML.Form.options_for_select(
                    @budget_form_options,
                    sole_allocation(transaction).budget_id
                  )}
                </select>
              </form>
              <button
                :if={is_nil(sole_allocation(transaction))}
                type="button"
                phx-click={JS.push("select_transaction") |> show_details()}
                phx-value-id={transaction.id}
                class="rounded-full bg-white/5 px-2 py-1 text-xs font-medium text-gray-300 ring-1 ring-inset ring-white/10"
              >
                Split
              </button>
            </div>
            <button
              type="button"
              phx-click="toggle_reviewed"
              phx-value-id={transaction.id}
              aria-label={if transaction.reviewed, do: "Mark unreviewed", else: "Mark reviewed"}
              aria-pressed={to_string(transaction.reviewed)}
              class="shrink-0"
            >
              <.icon
                name={if transaction.reviewed, do: "pi-check-circle-fill", else: "pi-circle"}
                class={if transaction.reviewed, do: "h-5 w-5 text-green-400", else: "h-5 w-5 text-gray-500"}
              />
            </button>
            <.icon name="pi-caret-right" class="h-5 w-5 shrink-0 text-gray-400" />
          </li>
        </ul>
        <.bulk_actions
          count={length(@selected_transactions)}
          budget_options={@budget_form_options}
        />
      </main>
      <aside
        id="transaction-details"
        class="hidden bg-black/10 lg:fixed lg:bottom-0 lg:right-0 lg:top-16 lg:w-96 lg:overflow-y-auto lg:border-l lg:border-white/5 text-white"
      >
        <.simple_form
          :let={f}
          :if={@changeset}
          id="transaction-form"
          for={@changeset}
          as={:transaction}
          phx-change="validate"
          phx-submit="submit"
        >
          <header class="flex items-center justify-between border-b border-white/5 p-6">
            <h2 class="text-base font-semibold leading-7">Edit transaction</h2>
            <button phx-click={hide_details()} class="text-sm font-semibold leading-6 text-blue-400">
              Save
            </button>
          </header>
          <div class="space-y-6 m-6">
            <.input type="text" label="Name" field={f[:name]} />
            <.input type="text" label="Amount" field={f[:amount]} />
            <.input type="date" label="Date" field={f[:date]} />
            <div>
              <%= if length(Ecto.Changeset.get_assoc(@changeset, :budget_allocations)) <= 1 do %>
                <.inputs_for :let={allocation_form} field={f[:budget_allocations]}>
                  <.input
                    type="select"
                    label={allocation_label(f[:amount].value)}
                    field={allocation_form[:budget_id]}
                    options={@budget_form_options}
                  />
                </.inputs_for>
              <% else %>
                <div class="grid grid-cols-10">
                  <div class="col-span-6">
                    {allocation_label(f[:amount].value)}
                  </div>
                  <div class="col-span-3">
                    Amount
                  </div>
                </div>
                <.inputs_for :let={allocation} field={f[:budget_allocations]}>
                  <input type="hidden" name="transaction[allocations_sort][]" value={allocation.index} />
                  <div class="grid grid-cols-10 items-center">
                    <div class="col-span-6 pr-2">
                      <.input type="select" field={allocation[:budget_id]} options={@budget_form_options} />
                    </div>
                    <div class="col-span-3">
                      <.input type="text" field={allocation[:amount]} />
                    </div>
                    <button
                      type="button"
                      class="cursor-pointer text-right mt-1"
                      name="transaction[allocations_drop][]"
                      value={allocation.index}
                      phx-click={JS.dispatch("change")}
                    >
                      <.icon name="pi-x-circle" />
                    </button>
                  </div>
                </.inputs_for>
                <input type="hidden" name="transaction[allocations_drop][]" />
              <% end %>
              <div class="flex justify-between mt-2">
                <button
                  type="button"
                  id="add-line"
                  name="transaction[allocations_sort][]"
                  value="new"
                  phx-click={JS.dispatch("change")}
                  class="text-sm font-semibold text-blue-400"
                >
                  Add line
                </button>
                <div class="relative">
                  <button
                    type="button"
                    class="text-sm font-semibold text-blue-400"
                    id="sort-menu-button"
                    phx-click={JS.toggle(to: "#split-options")}
                  >
                    Apply Split
                  </button>
                  <div
                    id="split-options"
                    class="hidden absolute right-0 z-10 mt-2.5 w-40 origin-top-right rounded-md bg-white max-h-96 overflow-auto shadow-lg ring-1 ring-gray-900/5 focus:outline-hidden divide-y"
                    phx-click-away={JS.hide(to: "#split-options")}
                  >
                    <button
                      :for={{split_name, split_id} <- @split_form_options}
                      type="button"
                      class="block px-3 py-2 w-full text-sm leading-6 text-gray-900 flex flex-col hover:bg-gray-200"
                      phx-click={JS.push("apply_split") |> JS.toggle(to: "#split-options")}
                      phx-value-split={split_id}
                    >
                      <div>{split_name}</div>
                    </button>
                  </div>
                </div>
              </div>
            </div>
            <.input type="textarea" label="Note" field={f[:note]} />
            <div
              :if={@changeset.data.transfer}
              class="flex items-center justify-between rounded-md bg-white/5 px-3 py-2 text-sm"
            >
              <span class="truncate text-gray-300">
                Transfer with {transfer_label(@changeset.data.transfer)}
              </span>
              <button
                type="button"
                id="remove-transfer"
                phx-click="remove_transfer"
                phx-value-id={@changeset.data.id}
                class="shrink-0 font-semibold text-blue-400"
              >
                Remove
              </button>
            </div>
            <div class="flex justify-between">
              <.input type="checkbox" label="Reviewed" field={f[:reviewed]} />
              <.input type="checkbox" label="Excluded" field={f[:excluded]} />
            </div>
          </div>
        </.simple_form>
      </aside>
    </div>
    """
  end

  def handle_event("validate", %{"transaction" => params}, socket) do
    changeset =
      socket.assigns.changeset.data
      |> Transaction.changeset(params)
      |> Map.put(:action, :validate)

    socket |> assign(:changeset, changeset) |> noreply()
  end

  def handle_event("submit", %{"transaction" => params}, socket) do
    scope = socket.assigns.current_scope
    transaction = socket.assigns.changeset.data

    case Transactions.update_transaction(scope, transaction, single_allocation(params)) do
      {:ok, _transaction} -> socket |> assign(:changeset, nil) |> fetch_data() |> noreply()
      {:error, changeset} -> socket |> assign(:changeset, changeset) |> noreply()
    end
  end

  def handle_event("apply_split", %{"split" => split_id}, socket) do
    {:ok, split} = Budgets.get_split(socket.assigns.current_scope, split_id)

    allocations =
      split.split_lines
      |> Enum.with_index()
      |> Map.new(fn {line, index} ->
        {to_string(index), %{"amount" => line.amount, "budget_id" => line.budget_id}}
      end)

    changeset =
      Transaction.changeset(socket.assigns.changeset.data, %{
        "budget_allocations" => allocations,
        "allocations_sort" => Enum.map(0..(map_size(allocations) - 1)//1, &to_string/1)
      })

    socket |> assign(:changeset, changeset) |> noreply()
  end

  def handle_event("toggle_select_transaction", %{"id" => id, "value" => "on"}, socket) do
    socket
    |> assign(:selected_transactions, Enum.uniq([id | socket.assigns.selected_transactions]))
    |> noreply()
  end

  def handle_event("toggle_select_transaction", %{"id" => id}, socket) do
    socket
    |> assign(:selected_transactions, Enum.filter(socket.assigns.selected_transactions, &(&1 != id)))
    |> noreply()
  end

  def handle_event("clear_selection", _params, socket) do
    socket |> clear_selection() |> noreply()
  end

  def handle_event("toggle_reviewed", %{"id" => id}, socket) do
    socket |> update_row(id, &%{"reviewed" => not &1.reviewed}) |> noreply()
  end

  def handle_event("set_spend_from", %{"transaction_id" => id, "budget_id" => budget_id}, socket) do
    socket |> update_row(id, &whole_amount_to(&1, budget_id)) |> noreply()
  end

  def handle_event("bulk_review", _params, socket) do
    socket |> update_selection(fn _transaction -> %{"reviewed" => true} end) |> noreply()
  end

  def handle_event("bulk_exclude", _params, socket) do
    socket |> update_selection(fn _transaction -> %{"excluded" => true} end) |> noreply()
  end

  def handle_event("bulk_spend_from", %{"budget" => budget_id}, socket) do
    socket |> update_selection(&whole_amount_to(&1, budget_id)) |> noreply()
  end

  def handle_event("bulk_transfer", _params, socket) do
    scope = socket.assigns.current_scope

    with [one_id, two_id] <- socket.assigns.selected_transactions,
         {:ok, one} <- Transactions.get_transaction(scope, id: one_id),
         {:ok, two} <- Transactions.get_transaction(scope, id: two_id),
         {:ok, {linked_one, linked_two}} <- Transactions.mark_as_transfer(scope, one, two) do
      socket
      |> clear_selection()
      |> refresh_row(linked_one)
      |> refresh_row(linked_two)
      |> noreply()
    else
      {:error, :transfer_not_allowed} ->
        socket
        |> put_flash(:error, "A transfer needs one transaction leaving an account and one arriving in another.")
        |> noreply()

      {:error, :already_transferred} ->
        socket
        |> put_flash(:error, "One of those transactions is already part of a transfer.")
        |> noreply()

      _no_pair ->
        noreply(socket)
    end
  end

  def handle_event("remove_transfer", %{"id" => id}, socket) do
    scope = socket.assigns.current_scope

    with {:ok, transaction} <- Transactions.get_transaction(scope, id: id),
         {:ok, removed} <- Transactions.remove_transfer(scope, transaction),
         {:ok, counterpart} <- Transactions.get_transaction(scope, id: transaction.transfer_id) do
      socket
      |> assign(:changeset, nil)
      |> refresh_row(removed)
      |> refresh_row(counterpart)
      |> noreply()
    else
      _not_a_transfer -> noreply(socket)
    end
  end

  def handle_event("delete", _params, socket) do
    scope = socket.assigns.current_scope

    socket =
      Enum.reduce(socket.assigns.selected_transactions, socket, fn id, socket ->
        case Transactions.get_transaction(scope, id: id) do
          {:ok, transaction} ->
            {:ok, deleted} = Transactions.delete_transaction(scope, transaction)
            stream_delete(socket, :transactions, deleted)

          {:error, :transaction_not_found} ->
            socket
        end
      end)

    socket |> clear_selection() |> noreply()
  end

  def handle_event("search", params, socket) do
    socket |> assign(:search, params["search"]) |> fetch_data() |> noreply()
  end

  def handle_event("change_reviewed_option", _params, socket) do
    socket
    |> assign(:show_reviewed, not socket.assigns.show_reviewed)
    |> fetch_data()
    |> noreply()
  end

  def handle_event("change_excluded_option", _params, socket) do
    socket
    |> assign(:show_excluded, not socket.assigns.show_excluded)
    |> fetch_data()
    |> noreply()
  end

  def handle_event("select_transaction", %{"id" => id}, socket) do
    {:ok, transaction} = Transactions.get_transaction(socket.assigns.current_scope, id: id)

    socket |> assign(:changeset, Transaction.changeset(transaction, %{})) |> noreply()
  end

  def handle_event("next-page", _params, socket) do
    socket |> paginate_transactions(socket.assigns.page + 1) |> noreply()
  end

  def handle_event("prev-page", _params, socket) do
    socket |> paginate_transactions(max(socket.assigns.page - 1, 1)) |> noreply()
  end

  def handle_event("close", _params, socket) do
    socket |> assign(:changeset, nil) |> noreply()
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
    scope = socket.assigns.current_scope

    socket
    |> assign(:budget_form_options, form_options(Budgets.list_budgets(scope)))
    |> assign(:split_form_options, form_options(Budgets.list_splits(scope)))
    |> assign(:selected_transactions, [])
    |> assign(:changeset, nil)
    |> assign(:page, 1)
    |> fetch_transactions()
  end

  defp fetch_transactions(socket) do
    transactions = page_of_transactions(socket, socket.assigns.page)

    socket
    |> assign(:end_of_timeline?, transactions == [])
    |> stream(:transactions, transactions, reset: true)
  end

  # Scrolling keeps a sliding window of pages in the stream. An empty page means we hit the end,
  # so leave what is already rendered alone rather than replacing it with nothing.
  defp paginate_transactions(socket, new_page) do
    %{per_page: per_page, page: current_page} = socket.assigns
    forward? = new_page >= current_page

    {transactions, at, limit} =
      case page_of_transactions(socket, new_page) do
        transactions when forward? -> {transactions, -1, -(per_page * 3)}
        transactions -> {Enum.reverse(transactions), 0, per_page * 3}
      end

    case transactions do
      [] ->
        assign(socket, :end_of_timeline?, forward?)

      transactions ->
        socket
        |> assign(:end_of_timeline?, false)
        |> assign(:page, new_page)
        |> stream(:transactions, transactions, at: at, limit: limit)
    end
  end

  defp page_of_transactions(socket, page) do
    Transactions.list_transactions(socket.assigns.current_scope,
      search: socket.assigns[:search],
      page: page,
      per_page: socket.assigns.per_page,
      show_reviewed: socket.assigns.show_reviewed,
      show_excluded: socket.assigns.show_excluded
    )
  end

  # Rewriting the one row that changed keeps the reader's place: a selection is usually made deep
  # into an infinitely scrolling list, and refetching would send them back to the top.
  defp update_row(socket, id, build_attrs) do
    scope = socket.assigns.current_scope

    with {:ok, transaction} <- Transactions.get_transaction(scope, id: id),
         {:ok, updated} <-
           Transactions.update_transaction(scope, transaction, build_attrs.(transaction)) do
      # The update is handed the record this just loaded, so what comes back still carries the
      # bank account the row renders.
      refresh_row(socket, updated)
    else
      _error -> socket
    end
  end

  defp update_selection(socket, build_attrs) do
    ids = socket.assigns.selected_transactions

    socket
    |> clear_selection()
    |> then(&Enum.reduce(ids, &1, fn id, socket -> update_row(socket, id, build_attrs) end))
  end

  # A row that is already rendered stays checked when the assign empties, because streams only
  # re-render the rows they are handed. The client clears the rest.
  defp clear_selection(socket) do
    socket
    |> assign(:selected_transactions, [])
    |> push_event("deselect-transactions", %{})
  end

  # A row leaves the list when the change no longer matches the filters, which is what makes
  # reviewing clear the queue.
  defp refresh_row(socket, transaction) do
    if visible?(socket, transaction),
      do: stream_insert(socket, :transactions, transaction),
      else: stream_delete(socket, :transactions, transaction)
  end

  defp visible?(socket, transaction) do
    (socket.assigns.show_reviewed or not transaction.reviewed) and
      (socket.assigns.show_excluded or not transaction.excluded)
  end

  defp whole_amount_to(transaction, budget_id) do
    %{"budget_allocations" => [%{"amount" => transaction.amount, "budget_id" => budget_id}]}
  end

  # A transaction with one allocation splits nothing, so the whole amount is spent from that
  # budget and the row can offer it directly.
  defp sole_allocation(%{budget_allocations: [allocation]}), do: allocation
  defp sole_allocation(_transaction), do: nil

  defp bank_member(%{bank_transaction: %{bank_account: %{bank_member: bank_member}}}) do
    if bank_member.logo, do: bank_member
  end

  defp bank_member(_transaction), do: nil

  defp bank_account(%{bank_transaction: %{bank_account: account}}), do: account
  defp bank_account(_transaction), do: nil

  # The dots stand in for the digits the bank does not give us, so the number reads as an account
  # rather than as a footnote.
  defp mask(number), do: "••••#{number}"

  defp transfer_label(%{bank_transaction: %{bank_account: account}}) do
    "#{account.name} #{mask(account.number)}"
  end

  defp transfer_label(transfer), do: transfer.name

  # On a failed submit the form hands back what the user typed, so this sees a string as often
  # as a Decimal.
  defp allocation_label(%Decimal{} = amount) do
    if Decimal.negative?(amount), do: "Spend from", else: "Add to"
  end

  defp allocation_label(amount) do
    if is_binary(amount) and String.starts_with?(String.trim(amount), "-"),
      do: "Spend from",
      else: "Add to"
  end

  # A transaction with a single allocation splits nothing, so that line carries the whole amount.
  defp single_allocation(%{"budget_allocations" => %{"0" => allocation} = allocations} = params)
       when map_size(allocations) == 1 do
    %{params | "budget_allocations" => %{"0" => Map.put(allocation, "amount", params["amount"])}}
  end

  defp single_allocation(params), do: params
end
