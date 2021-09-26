/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL query operation: GetTransaction
// ====================================================

export interface GetTransaction_transaction_budgetAllocations_budget {
  __typename: "Budget";
  id: string;
  name: string;
}

export interface GetTransaction_transaction_budgetAllocations {
  __typename: "BudgetAllocation";
  id: string;
  amount: Decimal;
  budget: GetTransaction_transaction_budgetAllocations_budget;
}

export interface GetTransaction_transaction_bankTransaction {
  __typename: "BankTranasction";
  name: string;
}

export interface GetTransaction_transaction {
  __typename: "Transaction";
  id: string;
  name: string;
  note: string | null;
  amount: Decimal;
  date: Date;
  reviewed: boolean;
  budgetAllocations: GetTransaction_transaction_budgetAllocations[];
  bankTransaction: GetTransaction_transaction_bankTransaction | null;
}

export interface GetTransaction {
  transaction: GetTransaction_transaction;
}

export interface GetTransactionVariables {
  id: string;
}
