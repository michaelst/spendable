/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL query operation: GetBudget
// ====================================================

export interface GetBudget_budget_budgetAllocations_transaction {
  __typename: "Transaction";
  id: string;
  name: string;
  date: Date;
  reviewed: boolean;
}

export interface GetBudget_budget_budgetAllocations {
  __typename: "BudgetAllocation";
  id: string;
  amount: Decimal;
  transaction: GetBudget_budget_budgetAllocations_transaction;
}

export interface GetBudget_budget_budgetAllocationTemplateLines_budgetAllocationTemplate {
  __typename: "BudgetAllocationTemplate";
  id: string;
  name: string;
}

export interface GetBudget_budget_budgetAllocationTemplateLines {
  __typename: "BudgetAllocationTemplateLine";
  id: string;
  amount: Decimal;
  budgetAllocationTemplate: GetBudget_budget_budgetAllocationTemplateLines_budgetAllocationTemplate;
}

export interface GetBudget_budget {
  __typename: "Budget";
  id: string;
  name: string;
  balance: Decimal;
  budgetAllocations: GetBudget_budget_budgetAllocations[];
  budgetAllocationTemplateLines: GetBudget_budget_budgetAllocationTemplateLines[];
}

export interface GetBudget {
  budget: GetBudget_budget;
}

export interface GetBudgetVariables {
  id: string;
}
