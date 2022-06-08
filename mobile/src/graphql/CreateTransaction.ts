/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

import { CreateTransactionInput } from "./globalTypes";

// ====================================================
// GraphQL mutation operation: CreateTransaction
// ====================================================

export interface CreateTransaction_createTransaction_result_budgetAllocations_budget {
  __typename: "Budget";
  id: string;
  name: string;
}

export interface CreateTransaction_createTransaction_result_budgetAllocations_transaction {
  __typename: "Transaction";
  id: string;
}

export interface CreateTransaction_createTransaction_result_budgetAllocations {
  __typename: "BudgetAllocation";
  id: string;
  amount: Decimal;
  budget: CreateTransaction_createTransaction_result_budgetAllocations_budget;
  transaction: CreateTransaction_createTransaction_result_budgetAllocations_transaction;
}

export interface CreateTransaction_createTransaction_result {
  __typename: "Transaction";
  id: string;
  name: string;
  note: string | null;
  amount: Decimal;
  date: Date;
  reviewed: boolean;
  budgetAllocations: CreateTransaction_createTransaction_result_budgetAllocations[];
}

export interface CreateTransaction_createTransaction {
  __typename: "CreateTransactionResult";
  /**
   * The successful result of the mutation
   */
  result: CreateTransaction_createTransaction_result | null;
}

export interface CreateTransaction {
  createTransaction: CreateTransaction_createTransaction | null;
}

export interface CreateTransactionVariables {
  input?: CreateTransactionInput | null;
}
