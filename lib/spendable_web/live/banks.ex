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
end
