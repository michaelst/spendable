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
  name: string;
}

export interface CreateTransaction_createTransaction_allocations {
  __typename: "Allocation";
  id: string;
  amount: Decimal;
  budget: CreateTransaction_createTransaction_allocations_budget;
}

export interface CreateTransaction_createTransaction {
  __typename: "Transaction";
  id: string;
  name: string | null;
  note: string | null;
  amount: Decimal;
  date: Date;
  allocations: CreateTransaction_createTransaction_allocations[];
}

export interface CreateTransaction {
  createTransaction: CreateTransaction_createTransaction;
}

export interface CreateTransactionVariables {
  amount: string;
  name?: string | null;
  date: string;
  note?: string | null;
  categoryId?: string | null;
  allocations?: AllocationInputObject[] | null;
}
