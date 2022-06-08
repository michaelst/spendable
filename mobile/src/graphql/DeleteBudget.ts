/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL mutation operation: DeleteBudget
// ====================================================

export interface DeleteBudget_deleteBudget_result {
  __typename: "Budget";
  id: string;
}

export interface DeleteBudget_deleteBudget {
  __typename: "DeleteBudgetResult";
  /**
   * The record that was successfully deleted
   */
  result: DeleteBudget_deleteBudget_result | null;
}

export interface DeleteBudget {
  deleteBudget: DeleteBudget_deleteBudget | null;
}

export interface DeleteBudgetVariables {
  id: string;
}
