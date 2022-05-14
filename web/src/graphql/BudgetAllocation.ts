/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL query operation: BudgetAllocation
// ====================================================

export interface BudgetAllocation_budgetAllocation_budget {
  __typename: "Budget";
  id: string;
  name: string;
}

export interface BudgetAllocation_budgetAllocation_transaction {
  __typename: "Transaction";
  id: string;
}

export interface BudgetAllocation_budgetAllocation {
  __typename: "BudgetAllocation";
  id: string;
  amount: Decimal;
  budget: BudgetAllocation_budgetAllocation_budget;
  transaction: BudgetAllocation_budgetAllocation_transaction;
}

export interface BudgetAllocation {
  budgetAllocation: BudgetAllocation_budgetAllocation;
}

export interface BudgetAllocationVariables {
  id: string;
}
