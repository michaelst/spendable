import { Main_budgets } from "src/graphql/Main"

export function subText(activeMonthIsCurrentMonth: Boolean, budget: Main_budgets) {
  if (budget.name === "Spendable") {
    return activeMonthIsCurrentMonth ? "AVAILABLE" : "SPENT"
  }

  return activeMonthIsCurrentMonth && !budget.trackSpendingOnly ? "REMAINING" : "SPENT"
}

export function amount(activeMonthIsCurrentMonth: Boolean, budget: Main_budgets, spendable: Decimal) {
  if (budget.name === "Spendable") {
    return activeMonthIsCurrentMonth ? spendable : budget.spent
  }

  return activeMonthIsCurrentMonth && !budget.trackSpendingOnly ? budget.balance : budget.spent
}