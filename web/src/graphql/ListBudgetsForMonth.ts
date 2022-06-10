/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL query operation: ListBudgetsForMonth
// ====================================================

export interface ListBudgetsForMonth_budgets {
  __typename: "Budget";
  id: string;
  name: string;
  balance: Decimal;
  trackSpendingOnly: boolean;
  archivedAt: NaiveDateTime | null;
  spent: Decimal;
}

export interface ListBudgetsForMonth {
  budgets: ListBudgetsForMonth_budgets[];
}

export interface ListBudgetsForMonthVariables {
  month: Date;
}
