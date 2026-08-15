defmodule SpendableWeb.Live.Templates do
  use SpendableWeb, :live_view

  import SpendableWeb.Utils.FormOptions

  alias Spendable.Budgets
  alias Spendable.Budgets.Schemas.BudgetAllocationTemplate

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(_params, _uri, socket) do
    socket |> fetch_data() |> noreply()
  end

  def render(assigns) do
    ~H"""
    <div>
      <main id="templates" phx-click={JS.push("close") |> hide_details()}>
        <header class="flex items-center justify-between border-b border-white/5 px-8 py-6">
          <h1 class="text-base font-semibold leading-7 text-white">Transaction templates</h1>
          <div class="flex gap-x-6">
            <button
              :if={is_nil(@changeset)}
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
              Archive ({length(@selected_templates)})
            </button>
            <button
              :if={not is_nil(@changeset)}
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
                    class="rounded-sm border-white/10 bg-white/5 text-white/5"
                  />
                </div>
                <div :if={to_string(template.id) in @selected_templates} class="pl-1 pr-2">
                  <input
                    type="checkbox"
                    value="true"
                    checked={true}
                    phx-click="uncheck_template"
                    phx-value-id={template.id}
                    class="rounded-sm border-white/10 bg-white/5 text-white/5"
                  />
                </div>
                <h2 class="min-w-0 text-sm font-semibold leading-6 text-white">
                  <span class="truncate">{template.name}</span>
                </h2>
              </div>
            </div>
            <div class="flex items-center">
              <.icon name="pi-caret-right" class="h-5 w-5 flex-none text-gray-400" />
            </div>
          </li>
        </ul>
      </main>
      <aside
        id="template-details"
        class="hidden bg-black/10 lg:fixed lg:bottom-0 lg:right-0 lg:top-16 lg:w-96 lg:overflow-y-auto lg:border-l lg:border-white/5 text-white"
      >
        <.simple_form
          :let={f}
          :if={@changeset}
          id="template-form"
          for={@changeset}
          as={:template}
          phx-change="validate"
          phx-submit="submit"
        >
          <header class="flex items-center justify-between border-b border-white/5 p-6">
            <h2 class="text-base font-semibold leading-7">Edit template</h2>
            <button phx-click={hide_details()} class="text-sm font-semibold leading-6 text-blue-400">
              Save
            </button>
          </header>
          <div class="space-y-6 m-6">
            <.input type="text" label="Name" field={f[:name]} />
            <div>
              <div class="grid grid-cols-10">
                <div class="col-span-6">
                  Budget
                </div>
                <div class="col-span-3">
                  Amount
                </div>
              </div>
              <.inputs_for :let={line} field={f[:budget_allocation_template_lines]}>
                <input type="hidden" name="template[lines_sort][]" value={line.index} />
                <div class="grid grid-cols-10 items-center">
                  <div class="col-span-6 pr-2">
                    <.input type="select" field={line[:budget_id]} options={@budget_form_options} />
                  </div>
                  <div class="col-span-3">
                    <.input type="text" field={line[:amount]} />
                  </div>
                  <button
                    type="button"
                    class="cursor-pointer text-right mt-1"
                    name="template[lines_drop][]"
                    value={line.index}
                    phx-click={JS.dispatch("change")}
                  >
                    <.icon name="pi-x-circle" class="text-red-400" />
                  </button>
                </div>
              </.inputs_for>
              <input type="hidden" name="template[lines_drop][]" />
              <div class="flex justify-between mt-2">
                <button
                  type="button"
                  id="split"
                  name="template[lines_sort][]"
                  value="new"
                  phx-click={JS.dispatch("change")}
                  class="text-sm font-semibold text-blue-400"
                >
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

  def handle_event("validate", %{"template" => params}, socket) do
    changeset =
      socket.assigns.changeset.data
      |> BudgetAllocationTemplate.changeset(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("submit", %{"template" => params}, socket) do
    scope = socket.assigns.current_scope

    result =
      case socket.assigns.changeset.data do
        %BudgetAllocationTemplate{id: nil} -> Budgets.create_template(scope, params)
        template -> Budgets.update_template(scope, template, params)
      end

    case result do
      {:ok, _template} -> socket |> assign(:changeset, nil) |> fetch_data() |> noreply()
      {:error, changeset} -> socket |> assign(:changeset, changeset) |> noreply()
    end
  end

  def handle_event("archive", _params, socket) do
    scope = socket.assigns.current_scope

    socket.assigns.templates
    |> Enum.filter(&(&1.id in socket.assigns.selected_templates))
    |> Enum.each(&Budgets.archive_template(scope, &1))

    {:noreply, fetch_data(socket)}
  end

  def handle_event("check_template", %{"id" => id}, socket) do
    socket
    |> assign(:selected_templates, Enum.uniq([id | socket.assigns.selected_templates]))
    |> noreply()
  end

  def handle_event("uncheck_template", %{"id" => id}, socket) do
    socket
    |> assign(:selected_templates, Enum.filter(socket.assigns.selected_templates, &(&1 != id)))
    |> noreply()
  end

  def handle_event("search", params, socket) do
    socket
    |> assign(:search, params["search"])
    |> fetch_data()
    |> noreply()
  end

  def handle_event("close", _params, socket) do
    {:noreply, assign(socket, :changeset, nil)}
  end

  def handle_event("new", _params, socket) do
    # Seeded with the owner because the line changesets read it off the parent, and with one
    # blank row, since a template with no lines allocates nothing.
    template = %BudgetAllocationTemplate{user_id: socket.assigns.current_scope.user.id}

    changeset =
      BudgetAllocationTemplate.changeset(template, %{
        "budget_allocation_template_lines" => %{"0" => %{}}
      })

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("select_template", %{"id" => id}, socket) do
    {:ok, template} = Budgets.get_template(socket.assigns.current_scope, id)

    {:noreply, assign(socket, :changeset, BudgetAllocationTemplate.changeset(template, %{}))}
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
    scope = socket.assigns.current_scope

    socket
    |> assign(:templates, Budgets.list_templates(scope, search: socket.assigns[:search]))
    |> assign(:budget_form_options, form_options(Budgets.list_budgets(scope)))
    |> assign(:changeset, nil)
    |> assign(:selected_templates, [])
  end
end
