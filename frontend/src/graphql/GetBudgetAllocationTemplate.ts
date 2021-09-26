/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL query operation: GetBudgetAllocationTemplate
// ====================================================

export interface GetBudgetAllocationTemplate_budgetAllocationTemplate_budgetAllocationTemplateLines_budget {
  __typename: "Budget";
  id: string;
  name: string;
}

export interface GetBudgetAllocationTemplate_budgetAllocationTemplate_budgetAllocationTemplateLines {
  __typename: "BudgetAllocationTemplateLine";
  id: string;
  amount: Decimal;
  budget: GetBudgetAllocationTemplate_budgetAllocationTemplate_budgetAllocationTemplateLines_budget;
}

export interface GetBudgetAllocationTemplate_budgetAllocationTemplate {
  __typename: "BudgetAllocationTemplate";
  id: string;
  name: string;
  budgetAllocationTemplateLines: GetBudgetAllocationTemplate_budgetAllocationTemplate_budgetAllocationTemplateLines[];
}

export interface GetBudgetAllocationTemplate {
  budgetAllocationTemplate: GetBudgetAllocationTemplate_budgetAllocationTemplate;
}

export interface GetBudgetAllocationTemplateVariables {
  id: string;
}
