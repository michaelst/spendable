defmodule SpendableWeb.Live.Templates do
  use SpendableWeb, :live_view

  alias Spendable.BudgetAllocationTemplate

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket |> fetch_data()}
  end

  def render(assigns) do
    ~H"""
    <div>
      <main id="templates" phx-click={JS.push("close") |> hide_details()}>
        <header class="flex items-center justify-between border-b border-white/5 px-8 py-6">
          <h1 class="text-base font-semibold leading-7 text-white">Transaction templates</h1>
          <div class="flex gap-x-6">
            <button
              :if={is_nil(@form)}
              id="new-template"
              type="button"
              phx-click={JS.push("new") |> show_details()}
              class="text-sm font-semibold leading-6 text-blue-400"
            >
              New
            </button>
            <button
              :if={not Enum.empty?(@selected_templates)}
              id="archive"
              type="button"
              phx-click="archive"
              class="text-sm font-semibold leading-6 text-blue-400"
            >
              Archive (<%= length(@selected_templates) %>)
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

        <ul role="list" class="divide-y divide-white/5">
          <li
            :for={template <- @templates}
            phx-click={JS.push("select_template") |> show_details()}
            phx-value-id={template.id}
            class="relative flex flex-row items-center justify-between space-x-4 py-6 pr-8"
          >
            <div class="min-w-0 flex-auto ml-1">
              <div class="flex items-center">
                <div :if={to_string(template.id) not in @selected_templates} class="pl-1 pr-2 opacity-0 hover:opacity-100">
                  <input
                    type="checkbox"
                    value="true"
                    checked={false}
                    phx-click="check_template"
                    phx-value-id={template.id}
                    class="rounded border-white/10 bg-white/5 text-white/5"
                  />
                </div>
                <div :if={to_string(template.id) in @selected_templates} class="pl-1 pr-2">
                  <input
                    type="checkbox"
                    value="true"
                    checked={true}
                    phx-click="uncheck_template"
                    phx-value-id={template.id}
                    class="rounded border-white/10 bg-white/5 text-white/5"
                  />
                </div>
                <h2 class="min-w-0 text-sm font-semibold leading-6 text-white">
                  <span class="truncate"><%= template.name %></span>
                </h2>
              </div>
            </div>
            <div class="flex items-center">
              <.icon name="hero-chevron-right-mini" class="h-5 w-5 flex-none text-gray-400" />
            </div>
          </li>
        </ul>
      </main>
      <aside
        id="template-details"
        class="hidden bg-black/10 lg:fixed lg:bottom-0 lg:right-0 lg:top-16 lg:w-96 lg:overflow-y-auto lg:border-l lg:border-white/5 text-white"
      >
        <.simple_form :if={@form} for={@form} phx-change="validate" phx-submit="submit">
          <header class="flex items-center justify-between border-b border-white/5 p-6">
            <h2 class="text-base font-semibold leading-7">Edit template</h2>
            <button phx-click={hide_details()} class="text-sm font-semibold leading-6 text-blue-400">
              Save
            </button>
          </header>
          <div class="space-y-6 m-6">
            <.input type="text" label="Name" field={@form[:name]} />
            <div>
              <div class="grid grid-cols-10">
                <div class="col-span-6">
                  Budget
                </div>
                <div class="col-span-3">
                  Amount
                </div>
              </div>
              <.inputs_for :let={allocation_form} field={@form[:budget_allocation_template_lines]}>
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
              <div class="flex justify-between mt-2">
                <button type="button" phx-click="split" class="text-sm font-semibold text-blue-400">
                  Split
                </button>
              </div>
            </div>
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
    |> Enum.each(&Spendable.Api.destroy!/1)

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

  def show_details(js \\ %JS{}) do
    js
    |> JS.show(to: "#template-details", transition: "fade-in")
    |> JS.add_class(
      "lg:pr-96",
      to: "#templates"
    )
  end

  def hide_details(js \\ %JS{}) do
    js
    |> JS.hide(to: "#template-details", transition: "fade-out")
    |> JS.remove_class(
      "lg:pr-96",
      to: "#templates",
      transition: "fade-out"
    )
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
