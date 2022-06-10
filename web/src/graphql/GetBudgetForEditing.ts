/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL query operation: GetBudgetForEditing
// ====================================================

export interface GetBudgetForEditing_budget {
  __typename: "Budget";
  id: string;
  name: string;
  adjustment: Decimal;
  balance: Decimal;
  trackSpendingOnly: boolean;
}

export interface GetBudgetForEditing {
  budget: GetBudgetForEditing_budget;
}

export interface GetBudgetForEditingVariables {
  id: string;
}
