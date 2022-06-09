/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL query operation: ListBudgets
// ====================================================

export interface ListBudgets_budgets {
  __typename: "Budget";
  id: string;
  name: string;
  archivedAt: NaiveDateTime | null;
}

export interface ListBudgets {
  budgets: ListBudgets_budgets[];
}
