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
  name: string;
}

export interface GetTransaction_transaction_allocations {
  __typename: "Allocation";
  id: string;
  amount: Decimal;
  budget: GetTransaction_transaction_allocations_budget;
}

export interface GetTransaction_transaction_bankTransaction {
  __typename: "BankTransaction";
  name: string;
}

export interface GetTransaction_transaction {
  __typename: "Transaction";
  id: string;
  name: string | null;
  note: string | null;
  amount: Decimal;
  date: Date;
  reviewed: boolean;
  allocations: GetTransaction_transaction_allocations[];
  bankTransaction: GetTransaction_transaction_bankTransaction | null;
}

export interface GetTransaction {
  transaction: GetTransaction_transaction;
}

export interface GetTransactionVariables {
  id: string;
}
