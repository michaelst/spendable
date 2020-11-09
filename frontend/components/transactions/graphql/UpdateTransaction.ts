/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

import { AllocationInputObject } from "./../../../graphql/globalTypes";

// ====================================================
// GraphQL mutation operation: UpdateTransaction
// ====================================================

export interface UpdateTransaction_updateTransaction_category {
  __typename: "Category";
  id: string | null;
}

export interface UpdateTransaction_updateTransaction_allocations_budget {
  __typename: "Budget";
  id: string;
}

export interface UpdateTransaction_updateTransaction_allocations {
  __typename: "Allocation";
  id: string;
  budget: UpdateTransaction_updateTransaction_allocations_budget;
  amount: Decimal;
}

export interface UpdateTransaction_updateTransaction {
  __typename: "Transaction";
  id: string;
  amount: Decimal;
  name: string | null;
  date: Date;
  note: string | null;
  category: UpdateTransaction_updateTransaction_category | null;
  allocations: UpdateTransaction_updateTransaction_allocations[];
}

export interface UpdateTransaction {
  updateTransaction: UpdateTransaction_updateTransaction;
}

export interface UpdateTransactionVariables {
  id: string;
  amount: string;
  name?: string | null;
  date?: string | null;
  note?: string | null;
  categoryId?: string | null;
  allocations: AllocationInputObject[];
}
