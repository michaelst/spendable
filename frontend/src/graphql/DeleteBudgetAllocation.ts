/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL mutation operation: DeleteBudgetAllocation
// ====================================================

export interface DeleteBudgetAllocation_deleteBudgetAllocation_result {
  __typename: "BudgetAllocation";
  id: string;
}

export interface DeleteBudgetAllocation_deleteBudgetAllocation {
  __typename: "DeleteBudgetAllocationResult";
  /**
   * The record that was successfully deleted
   */
  result: DeleteBudgetAllocation_deleteBudgetAllocation_result | null;
}

export interface DeleteBudgetAllocation {
  deleteBudgetAllocation: DeleteBudgetAllocation_deleteBudgetAllocation | null;
}

export interface DeleteBudgetAllocationVariables {
  id: string;
}
