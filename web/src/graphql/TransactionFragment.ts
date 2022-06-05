/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL fragment: TransactionFragment
// ====================================================

export interface TransactionFragment_budgetAllocations_budget {
  __typename: "Budget";
  id: string;
  name: string;
}

export interface TransactionFragment_budgetAllocations {
  __typename: "BudgetAllocation";
  id: string;
  amount: Decimal;
  budget: TransactionFragment_budgetAllocations_budget;
}

export interface TransactionFragment {
  __typename: "Transaction";
  id: string;
  name: string;
  note: string | null;
  amount: Decimal;
  date: Date;
  reviewed: boolean;
  budgetAllocations: TransactionFragment_budgetAllocations[];
}
