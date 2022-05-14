/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL query operation: ListBudgetAllocationTemplates
// ====================================================

export interface ListBudgetAllocationTemplates_budgetAllocationTemplates_budgetAllocationTemplateLines_budget {
  __typename: "Budget";
  id: string;
  name: string;
}

export interface ListBudgetAllocationTemplates_budgetAllocationTemplates_budgetAllocationTemplateLines {
  __typename: "BudgetAllocationTemplateLine";
  id: string;
  amount: Decimal;
  budget: ListBudgetAllocationTemplates_budgetAllocationTemplates_budgetAllocationTemplateLines_budget;
}

export interface ListBudgetAllocationTemplates_budgetAllocationTemplates {
  __typename: "BudgetAllocationTemplate";
  id: string;
  name: string;
  budgetAllocationTemplateLines: ListBudgetAllocationTemplates_budgetAllocationTemplates_budgetAllocationTemplateLines[];
}

export interface ListBudgetAllocationTemplates {
  budgetAllocationTemplates: ListBudgetAllocationTemplates_budgetAllocationTemplates[];
}
