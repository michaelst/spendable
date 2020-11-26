/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL mutation operation: CreateAllocation
// ====================================================

export interface CreateAllocation_createAllocation_budget {
  __typename: "Budget";
  id: string;
  name: string;
}

export interface CreateAllocation_createAllocation {
  __typename: "Allocation";
  id: string;
  amount: Decimal;
  budget: CreateAllocation_createAllocation_budget;
}

export interface CreateAllocation {
  createAllocation: CreateAllocation_createAllocation;
}

export interface CreateAllocationVariables {
  transactionId: string;
  amount: Decimal;
  budgetId: string;
}
