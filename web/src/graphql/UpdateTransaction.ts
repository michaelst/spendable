/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

import { UpdateTransactionInput } from "./globalTypes";

// ====================================================
// GraphQL mutation operation: UpdateTransaction
// ====================================================

export interface UpdateTransaction_updateTransaction_result_budgetAllocations_budget {
  __typename: "Budget";
  id: string;
  name: string;
}

export interface UpdateTransaction_updateTransaction_result_budgetAllocations_transaction {
  __typename: "Transaction";
  id: string;
}

export interface UpdateTransaction_updateTransaction_result_budgetAllocations {
  __typename: "BudgetAllocation";
  id: string;
  amount: Decimal;
  budget: UpdateTransaction_updateTransaction_result_budgetAllocations_budget;
  transaction: UpdateTransaction_updateTransaction_result_budgetAllocations_transaction;
}

export interface UpdateTransaction_updateTransaction_result {
  __typename: "Transaction";
  id: string;
  name: string;
  note: string | null;
  amount: Decimal;
  date: Date;
  reviewed: boolean;
  budgetAllocations: UpdateTransaction_updateTransaction_result_budgetAllocations[];
}

export interface UpdateTransaction_updateTransaction {
  __typename: "UpdateTransactionResult";
  /**
   * The successful result of the mutation
   */
  result: UpdateTransaction_updateTransaction_result | null;
}

export interface UpdateTransaction {
  updateTransaction: UpdateTransaction_updateTransaction | null;
}

export interface UpdateTransactionVariables {
  id: string;
  input?: UpdateTransactionInput | null;
}
