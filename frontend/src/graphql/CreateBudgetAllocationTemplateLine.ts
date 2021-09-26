/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

import { CreateBudgetAllocationTemplateLineInput } from "./globalTypes";

// ====================================================
// GraphQL mutation operation: CreateBudgetAllocationTemplateLine
// ====================================================

export interface CreateBudgetAllocationTemplateLine_createBudgetAllocationTemplateLine_result_budget {
  __typename: "Budget";
  id: string;
}

export interface CreateBudgetAllocationTemplateLine_createBudgetAllocationTemplateLine_result_budgetAllocationTemplate {
  __typename: "BudgetAllocationTemplate";
  id: string;
}

export interface CreateBudgetAllocationTemplateLine_createBudgetAllocationTemplateLine_result {
  __typename: "BudgetAllocationTemplateLine";
  id: string;
  amount: Decimal;
  budget: CreateBudgetAllocationTemplateLine_createBudgetAllocationTemplateLine_result_budget;
  budgetAllocationTemplate: CreateBudgetAllocationTemplateLine_createBudgetAllocationTemplateLine_result_budgetAllocationTemplate;
}

export interface CreateBudgetAllocationTemplateLine_createBudgetAllocationTemplateLine {
  __typename: "CreateBudgetAllocationTemplateLineResult";
  /**
   * The successful result of the mutation
   */
  result: CreateBudgetAllocationTemplateLine_createBudgetAllocationTemplateLine_result | null;
}

export interface CreateBudgetAllocationTemplateLine {
  createBudgetAllocationTemplateLine: CreateBudgetAllocationTemplateLine_createBudgetAllocationTemplateLine | null;
}

export interface CreateBudgetAllocationTemplateLineVariables {
  input?: CreateBudgetAllocationTemplateLineInput | null;
}
