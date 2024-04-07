defmodule SpendableWeb.Live.Banks do
  use SpendableWeb, :live_view

  alias Spendable.BankMember
  alias Spendable.Budget

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket |> assign(selected_bank_member_id: nil, form: nil) |> fetch_data()}
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
              <.icon
                :if={@selected_bank_member_id != bank_member.id}
                name="hero-chevron-right-mini"
                class="h-5 w-5 flex-none text-gray-400"
              />
              <.icon
                :if={@selected_bank_member_id == bank_member.id}
                name="hero-chevron-down-mini"
                class="h-5 w-5 flex-none text-gray-400"
              />
            </div>
            <li
              :for={bank_account <- bank_member.bank_accounts}
              :if={@selected_bank_member_id == bank_member.id}
              class="relative flex flex-row items-center justify-between space-x-4 px-4 py-6 sm:px-6 lg:px-8"
            >
              <div class="flex-1 pl-10">
                <div class="flex items-center">
                  <h2 class="min-w-0 text-sm font-semibold leading-6 text-gray-400 flex flex-col">
                    <span class="truncate"><%= bank_account.name %> *<%= bank_account.number %></span>
                    <span class="truncate uppercase mt-1 text-xs text-gray-600"><%= bank_account.sub_type %></span>
                  </h2>
                </div>
              </div>
              <div class="pr-8">
                <.form :let={f} for={bank_account_form(bank_account)} phx-change="assign_budget">
                  <.input type="hidden" field={f[:id]} />
                  <.input type="select" field={f[:budget_id]} options={[{"Assign to budget", nil} | @budget_form_options]} />
                </.form>
              </div>
              <div>
                <.switch id={bank_account.id} enabled={bank_account.sync} on_toggle="toggle_sync" />
              </div>
            </li>
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

    {:noreply, fetch_data(socket)}
  end

  def handle_event("toggle_sync", %{"id" => id}, socket) do
    bank_member = Enum.find(socket.assigns.bank_members, &(&1.id == socket.assigns.selected_bank_member_id))
    bank_account = Enum.find(bank_member.bank_accounts, &(&1.id == id))

    bank_account
    |> Ash.Changeset.for_update(:update, %{sync: !bank_account.sync})
    |> Spendable.Api.update!()

    {:noreply, fetch_data(socket)}
  end

  def handle_event("assign_budget", %{"form" => %{"id" => id, "budget_id" => budget_id}}, socket) do
    bank_member = Enum.find(socket.assigns.bank_members, &(&1.id == socket.assigns.selected_bank_member_id))
    bank_account = Enum.find(bank_member.bank_accounts, &(&1.id == id))

    bank_account
    |> Ash.Changeset.for_update(:update, %{budget_id: budget_id})
    |> Spendable.Api.update!()

    {:noreply, fetch_data(socket)}
  end

  def handle_event("search", params, socket) do
    {:noreply,
     socket
     |> assign(:search, params["search"])
     |> fetch_data()}
  end

  def handle_event("select_bank_member", %{"id" => id}, socket) do
    if socket.assigns.selected_bank_member_id == id do
      {:noreply, assign(socket, selected_bank_member_id: nil)}
    else
      {:noreply, assign(socket, selected_bank_member_id: id)}
    end
  end

  defp fetch_data(socket) do
    budget_form_options = Budget.form_options(socket.assigns.current_user.id)

    bank_members =
      BankMember.list(socket.assigns.current_user.id,
        search: socket.assigns[:search]
      )

    assign(socket, bank_members: bank_members, budget_form_options: budget_form_options)
  end

  defp bank_account_form(bank_account) do
    bank_account
    |> AshPhoenix.Form.for_update(:update,
      api: Spendable.Api,
      forms: [auto?: true]
    )
    |> to_form()
  end
end
