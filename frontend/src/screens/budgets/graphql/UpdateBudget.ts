/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL mutation operation: UpdateBudget
// ====================================================

export interface UpdateBudget_updateBudget {
  __typename: "Budget";
  id: string;
  name: string;
  balance: Decimal;
  goal: Decimal | null;
}

export interface UpdateBudget {
  updateBudget: UpdateBudget_updateBudget;
}

export interface UpdateBudgetVariables {
  id: string;
  name: string;
  balance: Decimal;
  goal?: Decimal | null;
}
