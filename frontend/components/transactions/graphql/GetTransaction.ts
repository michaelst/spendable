/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL query operation: GetTransaction
// ====================================================

export interface GetTransaction_transaction_allocations_budget {
  __typename: "Budget";
  id: string;
}

export interface GetTransaction_transaction_allocations {
  __typename: "Allocation";
  id: string;
  budget: GetTransaction_transaction_allocations_budget;
  amount: Decimal;
}

export interface GetTransaction_transaction_category {
  __typename: "Category";
  id: string | null;
}

export interface GetTransaction_transaction_bankTransaction {
  __typename: "BankTransaction";
  name: string;
  pending: boolean;
}

export interface GetTransaction_transaction {
  __typename: "Transaction";
  name: string | null;
  note: string | null;
  amount: Decimal;
  date: Date;
  allocations: GetTransaction_transaction_allocations[];
  category: GetTransaction_transaction_category | null;
  bankTransaction: GetTransaction_transaction_bankTransaction | null;
}

export interface GetTransaction {
  transaction: GetTransaction_transaction;
}

export interface GetTransactionVariables {
  id: string;
}
