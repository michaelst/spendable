/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL mutation operation: DeleteBudgetAllocationTemplate
// ====================================================

export interface DeleteBudgetAllocationTemplate_deleteBudgetAllocationTemplate_result {
  __typename: "BudgetAllocationTemplate";
  id: string;
}

export interface DeleteBudgetAllocationTemplate_deleteBudgetAllocationTemplate {
  __typename: "DeleteBudgetAllocationTemplateResult";
  /**
   * The record that was successfully deleted
   */
  result: DeleteBudgetAllocationTemplate_deleteBudgetAllocationTemplate_result | null;
}

export interface DeleteBudgetAllocationTemplate {
  deleteBudgetAllocationTemplate: DeleteBudgetAllocationTemplate_deleteBudgetAllocationTemplate | null;
}

export interface DeleteBudgetAllocationTemplateVariables {
  id: string;
}
