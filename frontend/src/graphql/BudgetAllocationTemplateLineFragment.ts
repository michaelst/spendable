/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL fragment: BudgetAllocationTemplateLineFragment
// ====================================================

export interface BudgetAllocationTemplateLineFragment_budget {
  __typename: "Budget";
  id: string;
  name: string;
}

export interface BudgetAllocationTemplateLineFragment_budgetAllocationTemplate {
  __typename: "BudgetAllocationTemplate";
  id: string;
}

export interface BudgetAllocationTemplateLineFragment {
  __typename: "BudgetAllocationTemplateLine";
  id: string;
  amount: Decimal;
  budget: BudgetAllocationTemplateLineFragment_budget;
  budgetAllocationTemplate: BudgetAllocationTemplateLineFragment_budgetAllocationTemplate;
}
