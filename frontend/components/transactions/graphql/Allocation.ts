/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL query operation: Allocation
// ====================================================

export interface Allocation_allocation_budget {
  __typename: "Budget";
  id: string;
  name: string;
}

export interface Allocation_allocation {
  __typename: "Allocation";
  id: string;
  amount: Decimal;
  budget: Allocation_allocation_budget;
}

export interface Allocation {
  allocation: Allocation_allocation;
}

export interface AllocationVariables {
  id: string;
}
