/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

import { CreateBudgetAllocationTemplateInput } from "./globalTypes";

// ====================================================
// GraphQL mutation operation: CreateBudgetAllocationTemplate
// ====================================================

export interface CreateBudgetAllocationTemplate_createBudgetAllocationTemplate_result_budgetAllocationTemplateLines_budget {
  __typename: "Budget";
  id: string;
  name: string;
}

export interface CreateBudgetAllocationTemplate_createBudgetAllocationTemplate_result_budgetAllocationTemplateLines {
  __typename: "BudgetAllocationTemplateLine";
  id: string;
  amount: Decimal;
  budget: CreateBudgetAllocationTemplate_createBudgetAllocationTemplate_result_budgetAllocationTemplateLines_budget;
}

export interface CreateBudgetAllocationTemplate_createBudgetAllocationTemplate_result {
  __typename: "BudgetAllocationTemplate";
  id: string;
  name: string;
  budgetAllocationTemplateLines: CreateBudgetAllocationTemplate_createBudgetAllocationTemplate_result_budgetAllocationTemplateLines[];
}

export interface CreateBudgetAllocationTemplate_createBudgetAllocationTemplate {
  __typename: "CreateBudgetAllocationTemplateResult";
  /**
   * The successful result of the mutation
   */
  result: CreateBudgetAllocationTemplate_createBudgetAllocationTemplate_result | null;
}

export interface CreateBudgetAllocationTemplate {
  createBudgetAllocationTemplate: CreateBudgetAllocationTemplate_createBudgetAllocationTemplate | null;
}

export interface CreateBudgetAllocationTemplateVariables {
  input?: CreateBudgetAllocationTemplateInput | null;
}
