/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL query operation: BudgetAllocationTemplateLine
// ====================================================

export interface BudgetAllocationTemplateLine_budgetAllocationTemplateLine_budget {
  __typename: "Budget";
  id: string;
}

export interface BudgetAllocationTemplateLine_budgetAllocationTemplateLine_budgetAllocationTemplate {
  __typename: "BudgetAllocationTemplate";
  id: string;
}

export interface BudgetAllocationTemplateLine_budgetAllocationTemplateLine {
  __typename: "BudgetAllocationTemplateLine";
  id: string;
  amount: Decimal;
  budget: BudgetAllocationTemplateLine_budgetAllocationTemplateLine_budget;
  budgetAllocationTemplate: BudgetAllocationTemplateLine_budgetAllocationTemplateLine_budgetAllocationTemplate;
}

export interface BudgetAllocationTemplateLine {
  budgetAllocationTemplateLine: BudgetAllocationTemplateLine_budgetAllocationTemplateLine;
}

export interface BudgetAllocationTemplateLineVariables {
  id: string;
}
