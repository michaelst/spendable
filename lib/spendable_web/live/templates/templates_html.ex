defmodule SpendableWeb.Live.Templates.HTML do
  use LiveViewNative.Component, format: :html
  use SpendableWeb, :html

  def render(assigns, _interface) do
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
                    <.icon name="hero-x-circle" class="text-red-400" />
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
end
