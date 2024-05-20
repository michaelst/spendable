defmodule SpendableWeb.Live.Templates do
  use SpendableWeb, :live_view

  alias Spendable.BudgetAllocationTemplate

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket |> fetch_data()}
  end

  def handle_event("validate", %{"form" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.form, params)
    {:noreply, assign(socket, form: form)}
  end

  def handle_event("submit", %{"form" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
      {:ok, _template} ->
        {:noreply, socket |> assign(:form, nil) |> fetch_data()}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  def handle_event("split", _params, socket) do
    form = AshPhoenix.Form.add_form(socket.assigns.form, [:budget_allocation_template_lines])
    {:noreply, assign(socket, form: form)}
  end

  def handle_event("archive", _params, socket) do
    socket.assigns.templates
    |> Enum.filter(&(to_string(&1.id) in socket.assigns.selected_templates))
    |> Enum.each(&Spendable.Api.destroy!(&1, actor: socket.assigns.current_user))

    {:noreply, fetch_data(socket)}
  end

  def handle_event("check_template", %{"id" => id}, socket) do
    {:noreply, assign(socket, selected_templates: Enum.uniq([id | socket.assigns.selected_templates]))}
  end

  def handle_event("uncheck_template", %{"id" => id}, socket) do
    {:noreply, assign(socket, selected_templates: Enum.filter(socket.assigns.selected_templates, &(&1 != id)))}
  end

  def handle_event("remove_allocation", %{"path" => path}, socket) do
    form = AshPhoenix.Form.remove_form(socket.assigns.form, path)
    {:noreply, assign(socket, form: form)}
  end

  def handle_event("search", params, socket) do
    {:noreply,
     socket
     |> assign(:search, params["search"])
     |> fetch_data()}
  end

  def handle_event("close", _params, socket) do
    {:noreply, assign(socket, :form, nil)}
  end

  def handle_event("new", _params, socket) do
    form =
      BudgetAllocationTemplate
      |> AshPhoenix.Form.for_create(:create,
        api: Spendable.Api,
        actor: socket.assigns.current_user,
        forms: [auto?: true]
      )
      |> to_form()
      |> AshPhoenix.Form.add_form([:budget_allocation_template_lines])

    {:noreply, assign(socket, :form, form)}
  end

  def handle_event("select_template", params, socket) do
    template =
      Enum.find(socket.assigns.templates, &(to_string(&1.id) == params["id"]))
      |> Spendable.Api.load!(:budget_allocation_template_lines)

    form =
      template
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

  defp fetch_data(socket) do
    templates =
      BudgetAllocationTemplate
      |> Ash.Query.for_read(:list, search: socket.assigns[:search])
      |> Spendable.Api.read!(actor: socket.assigns.current_user)

    budget_form_options = BudgetAllocationTemplate.budget_form_options(socket.assigns.current_user.id)

    assign(socket,
      templates: templates,
      budget_form_options: budget_form_options,
      form: nil,
      selected_templates: []
    )
  end
end
