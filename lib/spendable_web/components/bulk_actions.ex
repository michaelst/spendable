defmodule SpendableWeb.Components.BulkActions do
  @moduledoc false
  use SpendableWeb, :html

  @doc """
  The actions that apply to a selection of transactions.

  It floats over the list rather than sitting in the header because a selection is usually made
  well down an infinitely scrolling page, where the header is out of reach.
  """
  attr :count, :integer, required: true
  attr :budget_options, :list, required: true

  def bulk_actions(assigns) do
    ~H"""
    <div
      :if={@count > 0}
      id="bulk-actions"
      class="fixed bottom-6 left-1/2 z-30 flex -translate-x-1/2 items-center gap-x-5 rounded-full bg-slate-700 px-5 py-3 text-sm font-semibold shadow-lg ring-1 ring-black/20"
    >
      <span class="text-gray-300">{@count} selected</span>
      <button type="button" phx-click="bulk_review" class="text-sky-400">
        Reviewed
      </button>
      <button type="button" phx-click="bulk_exclude" class="text-sky-400">
        Excluded
      </button>
      <button
        type="button"
        id="bulk-transfer"
        phx-click="bulk_transfer"
        disabled={@count != 2}
        class="text-sky-400 disabled:text-gray-500"
      >
        Transfer
      </button>
      <.dropdown id="bulk-spend-from">
        <:trigger>
          <button type="button" class="text-sky-400">
            Spend from <.icon name="pi-caret-up-down" class="h-3 w-3" />
          </button>
        </:trigger>
        <div class="absolute bottom-full right-0 z-10 mb-3 max-h-96 w-48 overflow-auto rounded-md bg-slate-700 shadow-lg ring-1 ring-black/5">
          <button
            :for={{budget_name, budget_id} <- @budget_options}
            type="button"
            phx-click="bulk_spend_from"
            phx-value-budget={budget_id}
            class="block w-full px-3 py-2 text-left font-normal text-gray-100 hover:bg-slate-600"
          >
            {budget_name}
          </button>
        </div>
      </.dropdown>
      <button type="button" id="delete" phx-click="delete" class="text-red-400">
        Delete
      </button>
      <button type="button" phx-click="clear_selection" aria-label="Clear selection">
        <.icon name="pi-x" class="h-4 w-4 text-gray-300" />
      </button>
    </div>
    """
  end
end
