/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL mutation operation: CreateBudget
// ====================================================

export interface CreateBudget_createBudget {
  __typename: "Budget";
  id: string;
  name: string;
  balance: Decimal;
  goal: Decimal | null;
}

export interface CreateBudget {
  createBudget: CreateBudget_createBudget;
}

export interface CreateBudgetVariables {
  name: string;
  balance: Decimal;
  goal?: Decimal | null;
}
