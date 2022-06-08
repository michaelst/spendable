/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL fragment: BudgetAllocationTemplateFragment
// ====================================================

export interface BudgetAllocationTemplateFragment_budgetAllocationTemplateLines_budget {
  __typename: "Budget";
  id: string;
  name: string;
}

export interface BudgetAllocationTemplateFragment_budgetAllocationTemplateLines {
  __typename: "BudgetAllocationTemplateLine";
  id: string;
  amount: Decimal;
  budget: BudgetAllocationTemplateFragment_budgetAllocationTemplateLines_budget;
}

export interface BudgetAllocationTemplateFragment {
  __typename: "BudgetAllocationTemplate";
  id: string;
  name: string;
  budgetAllocationTemplateLines: BudgetAllocationTemplateFragment_budgetAllocationTemplateLines[];
}
