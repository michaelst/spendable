/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL query operation: ListTransactions
// ====================================================

export interface ListTransactions_transactions {
  __typename: "Transaction";
  id: string;
  name: string | null;
  amount: Decimal;
  date: Date;
}

export interface ListTransactions {
  transactions: ListTransactions_transactions[];
}

export interface ListTransactionsVariables {
  offset?: number | null;
}
