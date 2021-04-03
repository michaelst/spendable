defmodule Spendable.Web.Schema do
  use Absinthe.Schema

  @apis [Spendable.Api]

  use AshGraphql, apis: @apis

  import_types(Absinthe.Type.Custom)

  import_types(Spendable.Banks.Account.Types)
  import_types(Spendable.Banks.Category.Types)
  import_types(Spendable.Banks.Member.Types)
  import_types(Spendable.Banks.Transaction.Types)
  import_types(Spendable.Budgets.Allocation.Types)
  import_types(Spendable.Budgets.AllocationTemplate.Types)
  import_types(Spendable.Budgets.AllocationTemplateLine.Types)
  import_types(Spendable.Budgets.Budget.Types)
  import_types(Spendable.Notifications.Settings.Types)
  import_types(Spendable.Tag.Types)
  import_types(Spendable.Transaction.Types)
  import_types(Spendable.User.Types)

  query do
    field :health, :string, resolve: fn _args, _resolution -> {:ok, "up"} end
    import_fields(:allocation_queries)
    import_fields(:allocation_template_line_queries)
    import_fields(:allocation_template_queries)
    import_fields(:bank_member_queries)
    import_fields(:budget_queries)
    import_fields(:category_queries)
    import_fields(:notification_settings_queries)
    import_fields(:tag_queries)
    import_fields(:transaction_queries)
    import_fields(:user_queries)
  end

  mutation do
    import_fields(:allocation_mutations)
    import_fields(:allocation_template_line_mutations)
    import_fields(:allocation_template_mutations)
    import_fields(:bank_account_mutations)
    import_fields(:bank_member_mutations)
    import_fields(:budget_mutations)
    import_fields(:notification_settings_mutations)
    import_fields(:tag_mutations)
    import_fields(:transaction_mutations)
    import_fields(:user_mutations)
  end

  def context(context) do
    loader =
      Dataloader.new()
      |> Dataloader.add_source(Spendable, Spendable.data())

    context
    |> Map.put(:loader, loader)
    |> AshGraphql.add_context(@apis)
  end

  def plugins() do
    [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
  end

  def middleware(middleware, _field, %{identifier: :mutation}) do
    # this middleware needs to append to the end
    # credo:disable-for-next-line Credo.Check.Refactor.AppendSingleItem
    middleware ++ [Spendable.Middleware.ChangesetErrors]
  end

  # if it's any other object keep things as is
  def middleware(middleware, _field, _object), do: middleware

  def pipeline(config, pipeline_opts) do
    config.schema_mod
    |> Absinthe.Pipeline.for_document(pipeline_opts)
    |> Absinthe.Pipeline.insert_after(Absinthe.Phase.Document.Complexity.Analysis, Spendable.Web.Utils.LogComplexity)
  end
end
