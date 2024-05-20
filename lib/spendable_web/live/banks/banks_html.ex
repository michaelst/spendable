defmodule SpendableWeb.Live.Banks.HTML do
  use LiveViewNative.Component, format: :html
  use SpendableWeb, :html

  def render(assigns, _interface) do
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
              class="flex items-center justify-between py-6 px-8"
            >
              <div class="pl-10 w-96">
                <div class="flex items-center">
                  <h2 class="min-w-0 text-sm font-semibold leading-6 text-gray-400 flex flex-col">
                    <span class="truncate"><%= bank_account.name %> *<%= bank_account.number %></span>
                    <span class="truncate uppercase mt-1 text-xs text-gray-600"><%= bank_account.sub_type %></span>
                  </h2>
                </div>
              </div>
              <div class="flex items-center space-x-8">
                <div class="text-gray-400"><%= Spendable.Utils.format_currency(bank_account.balance) %></div>
                <div class="-mt-2">
                  <.form :let={f} for={bank_account_form(bank_account)} phx-change="assign_budget">
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

  defp bank_account_form(bank_account) do
    bank_account
    |> AshPhoenix.Form.for_update(:update,
      api: Spendable.Api,
      forms: [auto?: true]
    )
    |> to_form()
  end
end
