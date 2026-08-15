defmodule SpendableWeb.Live.Banks do
  use SpendableWeb, :live_view

  import SpendableWeb.Utils.FormOptions

  alias Spendable.Banks
  alias Spendable.Banks.Schemas.BankAccount
  alias Spendable.Budgets

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(_params, _uri, socket) do
    socket
    |> assign(:selected_bank_member_id, nil)
    |> fetch_data()
    |> noreply()
  end

  def render(assigns) do
    ~H"""
    <div>
      <main id="banks" phx-hook="Plaid">
        <header class="flex items-center justify-between border-b border-white/5 px-4 py-4 sm:px-6 sm:py-6 lg:px-8">
          <h1 class="text-base font-semibold leading-7 text-white">Banks</h1>
          <button id="open-plaid-link" phx-click="open_plaid_link" class="text-sm font-semibold leading-6 text-sky-400">
            New
          </button>
        </header>

        <ul role="list" class="divide-y divide-white/5">
          <li
            :for={bank_member <- @bank_members}
            phx-click="select_bank_member"
            phx-value-id={bank_member.id}
            class="relative flex flex-row items-center justify-between space-x-4 px-4 py-6 sm:px-6 lg:px-8"
          >
            <div class="min-w-0">
              <div class="flex items-center">
                <img src={"data:image/png;base64,#{bank_member.logo}"} alt="bank logo" class="h-8 mr-2" />
                <h2 class="min-w-0 text-sm font-semibold leading-6 text-white">
                  <span class="truncate">{bank_member.name}</span>
                </h2>
              </div>
            </div>
            <div class="flex items-center">
              <div :if={bank_member.status != "CONNECTED"} class="min-w-0 flex-auto mr-4">
                <div class="flex items-center gap-x-3">
                  <h2 class="w-full text-sm font-semibold leading-6 text-red-500 text-right">
                    <span class="truncate">
                      Reconnect <.icon name="pi-warning-circle" />
                    </span>
                  </h2>
                </div>
              </div>
              <.icon
                :if={@selected_bank_member_id != bank_member.id}
                name="pi-caret-right"
                class="h-5 w-5 flex-none text-gray-400"
              />
              <.icon
                :if={@selected_bank_member_id == bank_member.id}
                name="pi-caret-down"
                class="h-5 w-5 flex-none text-gray-400"
              />
            </div>
            <li
              :for={bank_account <- bank_member.bank_accounts}
              :if={@selected_bank_member_id == bank_member.id}
              class="flex items-center justify-between py-6 px-8"
            >
              <div class="pl-10 w-96">
                <div class="flex items-center">
                  <h2 class={[
                    if(bank_account.sync, do: "text-white", else: "text-gray-500"),
                    "min-w-0 text-sm font-semibold leading-6 flex flex-col"
                  ]}>
                    <span class="truncate">{bank_account.name} *{bank_account.number}</span>
                    <span class="truncate uppercase mt-1 text-xs text-gray-400">{bank_account.sub_type}</span>
                  </h2>
                </div>
              </div>
              <div class="flex items-center space-x-8">
                <div class={if bank_account.sync, do: "text-white", else: "text-gray-500"}>
                  {Spendable.Utils.format_currency(bank_account.balance)}
                </div>
                <div class="-mt-2">
                  <.form :let={f} for={bank_account_form(bank_account)} as={:bank_account} phx-change="assign_budget">
                    <.input type="hidden" field={f[:id]} />
                    <.input
                      type="select"
                      field={f[:budget_id]}
                      options={[{"Assign to budget", nil} | @budget_form_options]}
                    />
                  </.form>
                </div>
                <div>
                  <.switch id={bank_account.id} enabled={bank_account.sync} on_toggle="toggle_sync" />
                </div>
              </div>
            </li>
          </li>
        </ul>
      </main>
    </div>
    """
  end

  def handle_event("open_plaid_link", _params, socket) do
    case Banks.get_link_token(socket.assigns.current_scope) do
      {:ok, token} -> socket |> push_event("open_plaid_link", %{"link_token" => token}) |> noreply()
      {:error, :bank_limit_reached} -> noreply(socket)
    end
  end

  def handle_event("add_bank", %{"public_token" => public_token}, socket) do
    Banks.create_bank_member_from_public_token(socket.assigns.current_scope, public_token)

    socket |> fetch_data() |> noreply()
  end

  def handle_event("toggle_sync", %{"id" => id}, socket) do
    bank_member = Enum.find(socket.assigns.bank_members, &(&1.id == socket.assigns.selected_bank_member_id))
    bank_account = Enum.find(bank_member.bank_accounts, &(&1.id == id))

    Banks.update_bank_account(socket.assigns.current_scope, bank_account, %{
      "sync" => not bank_account.sync
    })

    socket |> fetch_data() |> noreply()
  end

  def handle_event("assign_budget", %{"bank_account" => %{"id" => id, "budget_id" => budget_id}}, socket) do
    bank_member = Enum.find(socket.assigns.bank_members, &(&1.id == socket.assigns.selected_bank_member_id))
    bank_account = Enum.find(bank_member.bank_accounts, &(&1.id == id))

    Banks.update_bank_account(socket.assigns.current_scope, bank_account, %{
      "budget_id" => budget_id
    })

    socket |> fetch_data() |> noreply()
  end

  def handle_event("search", params, socket) do
    socket |> assign(:search, params["search"]) |> fetch_data() |> noreply()
  end

  def handle_event("select_bank_member", %{"id" => id}, socket) do
    selected = if socket.assigns.selected_bank_member_id == id, do: nil, else: id

    socket |> assign(:selected_bank_member_id, selected) |> noreply()
  end

  defp fetch_data(socket) do
    budget_form_options = form_options(Budgets.list_budgets(socket.assigns.current_scope))

    bank_members =
      Banks.list_bank_members(socket.assigns.current_scope, search: socket.assigns[:search])

    socket
    |> assign(:bank_members, bank_members)
    |> assign(:budget_form_options, budget_form_options)
  end

  # One tiny form per account, so each row's select posts only its own id and budget.
  defp bank_account_form(bank_account) do
    BankAccount.changeset(bank_account, %{})
  end
end
