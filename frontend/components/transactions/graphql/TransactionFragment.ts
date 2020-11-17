/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL fragment: TransactionFragment
// ====================================================

export interface TransactionFragment_allocations_budget {
  __typename: "Budget";
  id: string;
  name: string;
}

export interface TransactionFragment_allocations {
  __typename: "Allocation";
  id: string;
  amount: Decimal;
  budget: TransactionFragment_allocations_budget;
}

export interface TransactionFragment {
  __typename: "Transaction";
  id: string;
  name: string | null;
  note: string | null;
  amount: Decimal;
  date: Date;
  allocations: TransactionFragment_allocations[];
}
