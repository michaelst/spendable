defmodule Spendable.Budgets.AllocationTemplate.Types do
  use Absinthe.Schema.Notation
  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  alias Spendable.Budgets.AllocationTemplate
  alias Spendable.Budgets.AllocationTemplate.Resolver
  alias Spendable.Middleware.CheckAuthentication
  alias Spendable.Middleware.LoadModel

  object :allocation_template do
    field :id, non_null(:id)
    field :name, non_null(:string)
    field :lines, :allocation_template_line |> non_null |> list_of |> non_null, resolve: dataloader(Spendable)
  end

  object :allocation_template_queries do
    field :allocation_template, non_null(:allocation_template) do
      middleware(CheckAuthentication)
      middleware(LoadModel, module: AllocationTemplate)
      arg(:id, non_null(:id))
      resolve(&Resolver.get/2)
    end

    field :allocation_templates, :allocation_template |> non_null |> list_of |> non_null do
      middleware(CheckAuthentication)
      resolve(&Resolver.list/2)
    end
  end

  object :allocation_template_mutations do
    field :create_allocation_template, :allocation_template do
      middleware(CheckAuthentication)
      arg(:name, :string)
      arg(:lines, list_of(:allocation_template_line_input_object))
      resolve(&Resolver.create/2)
    end

    field :update_allocation_template, :allocation_template do
      middleware(CheckAuthentication)
      middleware(LoadModel, module: AllocationTemplate)
      arg(:id, non_null(:id))
      arg(:name, :string)
      arg(:lines, list_of(:allocation_template_line_input_object))
      resolve(&Resolver.update/2)
    end

    field :delete_allocation_template, :allocation_template do
      middleware(CheckAuthentication)
      middleware(LoadModel, module: AllocationTemplate)
      arg(:id, non_null(:id))
      resolve(&Resolver.delete/2)
    end
  end
end
