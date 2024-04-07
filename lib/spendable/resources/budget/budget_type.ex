defmodule Spendable.Resources.Budget.BudgetType do
  use Ash.Type.Enum, values: [:tracking, :envelope, :goal]
end
