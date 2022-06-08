/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL mutation operation: DeleteBudgetAllocationTemplateLine
// ====================================================

export interface DeleteBudgetAllocationTemplateLine_deleteBudgetAllocationTemplateLine_result {
  __typename: "BudgetAllocationTemplateLine";
  id: string;
}

export interface DeleteBudgetAllocationTemplateLine_deleteBudgetAllocationTemplateLine {
  __typename: "DeleteBudgetAllocationTemplateLineResult";
  /**
   * The record that was successfully deleted
   */
  result: DeleteBudgetAllocationTemplateLine_deleteBudgetAllocationTemplateLine_result | null;
}

export interface DeleteBudgetAllocationTemplateLine {
  deleteBudgetAllocationTemplateLine: DeleteBudgetAllocationTemplateLine_deleteBudgetAllocationTemplateLine | null;
}

export interface DeleteBudgetAllocationTemplateLineVariables {
  id: string;
}
