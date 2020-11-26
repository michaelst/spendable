/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

import { AllocationInputObject } from "./../../../graphql/globalTypes";

// ====================================================
// GraphQL mutation operation: UpdateTransaction
// ====================================================

export interface UpdateTransaction_updateTransaction_allocations_budget {
  __typename: "Budget";
  id: string;
  name: string;
}

export interface UpdateTransaction_updateTransaction_allocations {
  __typename: "Allocation";
  id: string;
  amount: Decimal;
  budget: UpdateTransaction_updateTransaction_allocations_budget;
}

export interface UpdateTransaction_updateTransaction {
  __typename: "Transaction";
  id: string;
  name: string | null;
  note: string | null;
  amount: Decimal;
  date: Date;
  allocations: UpdateTransaction_updateTransaction_allocations[];
}

export interface UpdateTransaction {
  updateTransaction: UpdateTransaction_updateTransaction;
}

export interface UpdateTransactionVariables {
  id: string;
  amount?: string | null;
  name?: string | null;
  date?: string | null;
  note?: string | null;
  allocations?: AllocationInputObject[] | null;
}
