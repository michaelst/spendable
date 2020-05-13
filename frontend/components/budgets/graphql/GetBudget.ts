/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL query operation: GetBudget
// ====================================================

export interface GetBudget_budget_recentAllocations_transaction_bankTransaction {
  __typename: "BankTransaction";
  pending: boolean;
}

export interface GetBudget_budget_recentAllocations_transaction {
  __typename: "Transaction";
  name: string | null;
  date: Date;
  bankTransaction: GetBudget_budget_recentAllocations_transaction_bankTransaction | null;
}

export interface GetBudget_budget_recentAllocations {
  __typename: "Allocation";
  id: string;
  amount: Decimal;
  transaction: GetBudget_budget_recentAllocations_transaction;
}

export interface GetBudget_budget_allocationTemplateLines_allocationTemplate {
  __typename: "AllocationTemplate";
  name: string;
}

export interface GetBudget_budget_allocationTemplateLines {
  __typename: "AllocationTemplateLine";
  id: string;
  amount: Decimal;
  allocationTemplate: GetBudget_budget_allocationTemplateLines_allocationTemplate;
}

export interface GetBudget_budget {
  __typename: "Budget";
  id: string;
  name: string;
  balance: Decimal;
  goal: Decimal | null;
  recentAllocations: GetBudget_budget_recentAllocations[];
  allocationTemplateLines: GetBudget_budget_allocationTemplateLines[];
}

export interface GetBudget {
  budget: GetBudget_budget;
}

export interface GetBudgetVariables {
  id: string;
}
