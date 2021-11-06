/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL fragment: BudgetAllocationFragment
// ====================================================

export interface BudgetAllocationFragment_budget {
  __typename: "Budget";
  id: string;
  name: string;
}

export interface BudgetAllocationFragment {
  __typename: "BudgetAllocation";
  id: string;
  amount: Decimal;
  budget: BudgetAllocationFragment_budget;
}
