defmodule SpendableWeb.Live.Transactions do
  use SpendableWeb, :live_view

  alias Spendable.Transaction
  alias Spendable.Utils

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(
       page: 1,
       per_page: 25,
       options: %{
         show_reviewed_transactions: true,
         show_excluded_transactions: false
       }
     )
     |> fetch_data()}
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

  def handle_event("change_reviewed_option", _params, socket) do
    {:noreply,
     socket
     |> assign(
       options:
         Map.put(
           socket.assigns.options,
           :show_reviewed_transactions,
           !socket.assigns.options.show_reviewed_transactions
         )
     )
     |> paginate_posts(1, true)}
  end

  def handle_event("change_excluded_option", _params, socket) do
    {:noreply,
     socket
     |> assign(
       options:
         Map.put(
           socket.assigns.options,
           :show_excluded_transactions,
           !socket.assigns.options.show_excluded_transactions
         )
     )
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
    %{per_page: per_page, page: page, options: options} = socket.assigns

    transactions =
      Transaction.list_transactions(socket.assigns.current_user.id,
        search: socket.assigns[:search],
        page: new_page,
        per_page: per_page,
        options: options
      )

    {transactions, at, limit} =
      if new_page >= page do
        {transactions, -1, per_page * 3 * -1}
      else
        {Enum.reverse(transactions), 0, per_page * 3}
      end

    case transactions do
      [] ->
        socket
        |> assign(end_of_timeline?: at == -1)
        |> stream(:transactions, transactions, at: at, limit: limit, reset: reset)

      [_ | _] = transactions ->
        socket
        |> assign(end_of_timeline?: false)
        |> assign(:page, new_page)
        |> stream(:transactions, transactions, at: at, limit: limit, reset: reset)
    end
  end
end
