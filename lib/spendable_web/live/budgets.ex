defmodule SpendableWeb.Live.Budgets do
  use SpendableWeb, :live_view

  alias Spendable.Budget
  alias Spendable.BankMember

  def mount(_params, _session, socket) do
    {:ok, fetch_data(socket)}
  end

  def handle_event("accounts_synced", %{"accounts" => accounts}, socket) do
    accounts = Jason.decode!(accounts)

    bank_member =
      BankMember
      |> Ash.Changeset.new(%{
        external_id: socket.assigns.current_user.id,
        name: "Apple",
        provider: "apple",
        status: "CONNECTED",
        logo:
          "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"
      })
      |> Spendable.Api.create!(
        upsert?: true,
        upsert_identity: :external_id,
        actor: socket.assigns.current_user
      )

    # Enum.each(accounts, fn %{type => accounts_for_type} ->
    #   Enum.each(accounts_for_type, fn %{_n => account} ->
    #   BankAccount
    #   |> Ash.Changeset.new(%{
    #     balance: 0,
    #     external_id: account["id"],
    #     name: account["displayName"],
    #     type: type,
    #     subtype: type,
    #     sync: true
    #     })
    #   |> Ash.Changeset.manage_relationship(:bank_member, member, type: :append_and_remove)
    #   |> Ash.Changeset.manage_relationship(:user, member.user, type: :append_and_remove)
    #   |> Api.create!(
    #     upsert?: true,
    #     upsert_identity: :external_id,
    #     actor: socket.assigns.current_user
    #   )
    #   end)
    # end)

    # [
    #   %{
    #     "liability" => %{
    #       "_0" => %{
    #         "accountDescription" => "Apple Card",
    #         "creditInformation" => %{
    #           "creditLimit" => %{"amount" => "16900", "currency" => "USD"},
    #           "minimumNextPaymentAmount" => %{
    #             "amount" => "362.58",
    #             "currency" => "USD"
    #           },
    #           "nextPaymentDueDate" => 738907197
    #         },
    #         "currencyCode" => "USD",
    #         "displayName" => "Apple Card",
    #         "id" => "C1D80EF4-7017-4B4F-A45C-0E98F729E175",
    #         "institutionName" => "Apple"
    #       }
    #     }
    #   },
    #   %{
    #     "asset" => %{
    #       "_0" => %{
    #         "accountDescription" => "Apple Cash",
    #         "currencyCode" => "USD",
    #         "displayName" => "Apple Cash",
    #         "id" => "E2FF7F2F-8BF9-416F-8C5D-28F8163DD53A",
    #         "institutionName" => "Apple"
    #       }
    #     }
    #   }
    # ]

    {:noreply, socket}
  end

  def handle_event("validate", %{"form" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.form, params)
    {:noreply, assign(socket, form: form)}
  end

  def handle_event("submit", %{"form" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
      {:ok, _budget} ->
        {:noreply, socket |> assign(:form, nil) |> fetch_data()}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
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
      Budget
      |> AshPhoenix.Form.for_create(:create,
        api: Spendable.Api,
        actor: socket.assigns.current_user,
        forms: [auto?: true]
      )
      |> to_form()

    {:noreply, assign(socket, :form, form)}
  end

  def handle_event("select_month", params, socket) do
    {:noreply,
     socket
     |> assign(:selected_month, Timex.parse!(params["month"], "{YYYY}-{0M}-{D}"))
     |> fetch_data()}
  end

  def handle_event("select_budget", params, socket) do
    budget =
      Enum.find(socket.assigns.budgets, &(to_string(&1.id) == params["id"]))

    form =
      budget
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

  def handle_event("archive", _params, socket) do
    socket.assigns.budgets
    |> Enum.filter(&(to_string(&1.id) in socket.assigns.selected_budgets))
    |> Enum.each(&Spendable.Api.destroy!(&1, actor: socket.assigns.current_user))

    {:noreply, fetch_data(socket)}
  end

  def handle_event("check_budget", %{"id" => id}, socket) do
    {:noreply, assign(socket, selected_budgets: Enum.uniq([id | socket.assigns.selected_budgets]))}
  end

  def handle_event("uncheck_budget", %{"id" => id}, socket) do
    {:noreply, assign(socket, selected_budgets: Enum.filter(socket.assigns.selected_budgets, &(&1 != id)))}
  end

  defp fetch_data(socket) do
    current_month = Date.utc_today() |> Timex.beginning_of_month()
    selected_month = socket.assigns[:selected_month] || current_month
    current_month_is_selected = Timex.equal?(selected_month, current_month)

    [spendable | budgets] =
      Budget
      |> Ash.Query.for_read(:list,
        selected_month: selected_month,
        search: socket.assigns[:search]
      )
      |> Spendable.Api.read!(actor: socket.assigns.current_user)

    budgets =
      if current_month_is_selected do
        [
          spendable,
          %Budget{
            name: "Credit Cards",
            type: :envelope,
            spent: Decimal.new("0"),
            balance:
              Spendable.BankMember.Storage.credit_card_balance(socket.assigns.current_user.id) |> Decimal.negate()
          }
          | budgets
        ]
      else
        [spendable | budgets]
      end

    user = Spendable.Api.load!(socket.assigns.current_user, [:spent_by_month, :spendable])

    socket
    |> assign(:current_user, user)
    |> assign(:selected_month, selected_month)
    |> assign(:selected_budgets, [])
    |> assign(:budgets, budgets)
    |> assign(:current_month_is_selected, current_month_is_selected)
    |> assign(:form, nil)
    |> push_event("request-finance-data", %{"test" => "test"})
  end
end
