import { ListBudgetsForMonth_budgets } from "../graphql/ListBudgetsForMonth"

export function subText(activeMonthIsCurrentMonth: Boolean, budget: ListBudgetsForMonth_budgets) {
  if (budget.name === "Spendable") {
    return activeMonthIsCurrentMonth ? "AVAILABLE" : "SPENT"
  }

  return activeMonthIsCurrentMonth && !budget.trackSpendingOnly ? "REMAINING" : "SPENT"
}

export function amount(activeMonthIsCurrentMonth: Boolean, budget: ListBudgetsForMonth_budgets) {
  return activeMonthIsCurrentMonth && !budget.trackSpendingOnly ? budget.balance : budget.spent
}