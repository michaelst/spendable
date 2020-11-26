/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL fragment: AllocationFragment
// ====================================================

export interface AllocationFragment_budget {
  __typename: "Budget";
  id: string;
  name: string;
}

export interface AllocationFragment {
  __typename: "Allocation";
  id: string;
  amount: Decimal;
  budget: AllocationFragment_budget;
}
