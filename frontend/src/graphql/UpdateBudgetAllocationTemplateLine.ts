/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

import { UpdateBudgetAllocationTemplateLineInput } from "./globalTypes";

// ====================================================
// GraphQL mutation operation: UpdateBudgetAllocationTemplateLine
// ====================================================

export interface UpdateBudgetAllocationTemplateLine_updateBudgetAllocationTemplateLine_result_budget {
  __typename: "Budget";
  id: string;
}

export interface UpdateBudgetAllocationTemplateLine_updateBudgetAllocationTemplateLine_result_budgetAllocationTemplate {
  __typename: "BudgetAllocationTemplate";
  id: string;
}

export interface UpdateBudgetAllocationTemplateLine_updateBudgetAllocationTemplateLine_result {
  __typename: "BudgetAllocationTemplateLine";
  id: string;
  amount: Decimal;
  budget: UpdateBudgetAllocationTemplateLine_updateBudgetAllocationTemplateLine_result_budget;
  budgetAllocationTemplate: UpdateBudgetAllocationTemplateLine_updateBudgetAllocationTemplateLine_result_budgetAllocationTemplate;
}

export interface UpdateBudgetAllocationTemplateLine_updateBudgetAllocationTemplateLine {
  __typename: "UpdateBudgetAllocationTemplateLineResult";
  /**
   * The successful result of the mutation
   */
  result: UpdateBudgetAllocationTemplateLine_updateBudgetAllocationTemplateLine_result | null;
}

export interface UpdateBudgetAllocationTemplateLine {
  updateBudgetAllocationTemplateLine: UpdateBudgetAllocationTemplateLine_updateBudgetAllocationTemplateLine | null;
}

export interface UpdateBudgetAllocationTemplateLineVariables {
  id: string;
  input?: UpdateBudgetAllocationTemplateLineInput | null;
}
