/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

import { UpdateBudgetAllocationTemplateInput } from "./globalTypes";

// ====================================================
// GraphQL mutation operation: UpdateBudgetAllocationTemplate
// ====================================================

export interface UpdateBudgetAllocationTemplate_updateBudgetAllocationTemplate_result_budgetAllocationTemplateLines_budget {
  __typename: "Budget";
  id: string;
  name: string;
}

export interface UpdateBudgetAllocationTemplate_updateBudgetAllocationTemplate_result_budgetAllocationTemplateLines {
  __typename: "BudgetAllocationTemplateLine";
  id: string;
  amount: Decimal;
  budget: UpdateBudgetAllocationTemplate_updateBudgetAllocationTemplate_result_budgetAllocationTemplateLines_budget;
}

export interface UpdateBudgetAllocationTemplate_updateBudgetAllocationTemplate_result {
  __typename: "BudgetAllocationTemplate";
  id: string;
  name: string;
  budgetAllocationTemplateLines: UpdateBudgetAllocationTemplate_updateBudgetAllocationTemplate_result_budgetAllocationTemplateLines[];
}

export interface UpdateBudgetAllocationTemplate_updateBudgetAllocationTemplate {
  __typename: "UpdateBudgetAllocationTemplateResult";
  /**
   * The successful result of the mutation
   */
  result: UpdateBudgetAllocationTemplate_updateBudgetAllocationTemplate_result | null;
}

export interface UpdateBudgetAllocationTemplate {
  updateBudgetAllocationTemplate: UpdateBudgetAllocationTemplate_updateBudgetAllocationTemplate | null;
}

export interface UpdateBudgetAllocationTemplateVariables {
  id: string;
  input?: UpdateBudgetAllocationTemplateInput | null;
}
