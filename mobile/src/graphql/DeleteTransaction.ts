/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL mutation operation: DeleteTransaction
// ====================================================

export interface DeleteTransaction_deleteTransaction_result {
  __typename: "Transaction";
  id: string;
}

export interface DeleteTransaction_deleteTransaction {
  __typename: "DeleteTransactionResult";
  /**
   * The record that was successfully deleted
   */
  result: DeleteTransaction_deleteTransaction_result | null;
}

export interface DeleteTransaction {
  deleteTransaction: DeleteTransaction_deleteTransaction | null;
}

export interface DeleteTransactionVariables {
  id: string;
}
