/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL query operation: ListTransactions
// ====================================================

export interface ListTransactions_transactions_allocations_budget {
  __typename: "Budget";
  id: string;
}

export interface ListTransactions_transactions_allocations {
  __typename: "Allocation";
  id: string;
  budget: ListTransactions_transactions_allocations_budget;
  amount: Decimal;
}

export interface ListTransactions_transactions_category {
  __typename: "Category";
  id: string | null;
}

export interface ListTransactions_transactions_bankTransaction {
  __typename: "BankTransaction";
  name: string;
  pending: boolean;
}

export interface ListTransactions_transactions {
  __typename: "Transaction";
  id: string;
  name: string | null;
  note: string | null;
  amount: Decimal;
  date: Date;
  allocations: ListTransactions_transactions_allocations[];
  category: ListTransactions_transactions_category | null;
  bankTransaction: ListTransactions_transactions_bankTransaction | null;
}

export interface ListTransactions {
  transactions: ListTransactions_transactions[];
}

export interface ListTransactionsVariables {
  offset: number;
}
