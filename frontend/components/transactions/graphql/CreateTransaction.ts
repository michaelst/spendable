/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

import { AllocationInputObject } from "./../../../graphql/globalTypes";

// ====================================================
// GraphQL mutation operation: CreateTransaction
// ====================================================

export interface CreateTransaction_createTransaction_allocations_budget {
  __typename: "Budget";
  id: string;
}

export interface CreateTransaction_createTransaction_allocations {
  __typename: "Allocation";
  id: string;
  budget: CreateTransaction_createTransaction_allocations_budget;
  amount: Decimal;
}

export interface CreateTransaction_createTransaction_category {
  __typename: "Category";
  id: string | null;
}

export interface CreateTransaction_createTransaction {
  __typename: "Transaction";
  id: string;
  name: string | null;
  note: string | null;
  amount: Decimal;
  date: Date;
  allocations: CreateTransaction_createTransaction_allocations[];
  category: CreateTransaction_createTransaction_category | null;
}

export interface CreateTransaction {
  createTransaction: CreateTransaction_createTransaction;
}

export interface CreateTransactionVariables {
  amount: string;
  name?: string | null;
  date?: string | null;
  note?: string | null;
  categoryId?: string | null;
  allocations: AllocationInputObject[];
}
