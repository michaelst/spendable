/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

import { UpdateBudgetAllocationInput } from "./globalTypes";

// ====================================================
// GraphQL mutation operation: UpdateBudgetAllocation
// ====================================================

export interface UpdateBudgetAllocation_updateBudgetAllocation_result_budget {
  __typename: "Budget";
  id: string;
  name: string;
}

export interface UpdateBudgetAllocation_updateBudgetAllocation_result_transaction {
  __typename: "Transaction";
  id: string;
}

export interface UpdateBudgetAllocation_updateBudgetAllocation_result {
  __typename: "BudgetAllocation";
  id: string;
  amount: Decimal;
  budget: UpdateBudgetAllocation_updateBudgetAllocation_result_budget;
  transaction: UpdateBudgetAllocation_updateBudgetAllocation_result_transaction;
}

export interface UpdateBudgetAllocation_updateBudgetAllocation {
  __typename: "UpdateBudgetAllocationResult";
  /**
   * The successful result of the mutation
   */
  result: UpdateBudgetAllocation_updateBudgetAllocation_result | null;
}

export interface UpdateBudgetAllocation {
  updateBudgetAllocation: UpdateBudgetAllocation_updateBudgetAllocation | null;
}

export interface UpdateBudgetAllocationVariables {
  id: string;
  input?: UpdateBudgetAllocationInput | null;
}
