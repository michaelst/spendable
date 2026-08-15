defmodule Spendable.Budgets do
  @moduledoc false

  alias Spendable.Budgets.Actions

  defdelegate list_budgets(scope, opts \\ []), to: Actions.ListBudgets
  defdelegate get_budget(scope, by), to: Actions.GetBudget
  defdelegate create_budget(scope, attrs), to: Actions.CreateBudget
  defdelegate update_budget(scope, budget, attrs), to: Actions.UpdateBudget
  defdelegate archive_budget(scope, budget), to: Actions.ArchiveBudget
  defdelegate find_or_create_spendable_budget(scope), to: Actions.FindOrCreateSpendableBudget
  defdelegate calculate_spendable(scope), to: Actions.CalculateSpendable
  defdelegate calculate_spent(scope, budgets, month), to: Actions.CalculateSpent
  defdelegate calculate_spent_by_month(scope), to: Actions.CalculateSpentByMonth

  defdelegate list_templates(scope, opts \\ []), to: Actions.ListTemplates
  defdelegate get_template(scope, id), to: Actions.GetTemplate
  defdelegate create_template(scope, attrs), to: Actions.CreateTemplate
  defdelegate update_template(scope, template, attrs), to: Actions.UpdateTemplate
  defdelegate archive_template(scope, template), to: Actions.ArchiveTemplate
end
