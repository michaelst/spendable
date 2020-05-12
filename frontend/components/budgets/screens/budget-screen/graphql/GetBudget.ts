/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL query operation: GetBudget
// ====================================================

export interface GetBudget_budget_recentAllocations_transaction_bankTransaction {
  __typename: "BankTransaction";
  pending: boolean | null;
}

export interface GetBudget_budget_recentAllocations_transaction {
  __typename: "Transaction";
  name: string | null;
  date: string | null;
  bankTransaction: GetBudget_budget_recentAllocations_transaction_bankTransaction | null;
}

export interface GetBudget_budget_recentAllocations {
  __typename: "Allocation";
  id: string | null;
  amount: string | null;
  transaction: GetBudget_budget_recentAllocations_transaction | null;
}

export interface GetBudget_budget_allocationTemplateLines_allocationTemplate {
  __typename: "AllocationTemplate";
  name: string | null;
}

export interface GetBudget_budget_allocationTemplateLines {
  __typename: "AllocationTemplateLine";
  id: string | null;
  amount: string | null;
  allocationTemplate: GetBudget_budget_allocationTemplateLines_allocationTemplate | null;
}

export interface GetBudget_budget {
  __typename: "Budget";
  id: string;
  name: string;
  balance: Decimal;
  goal: Decimal | null;
  recentAllocations: (GetBudget_budget_recentAllocations | null)[] | null;
  allocationTemplateLines: (GetBudget_budget_allocationTemplateLines | null)[] | null;
}

export interface GetBudget {
  budget: GetBudget_budget | null;
}

export interface GetBudgetVariables {
  id: string;
}
