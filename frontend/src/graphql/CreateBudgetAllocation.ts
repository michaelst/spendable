/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

import { CreateBudgetAllocationInput } from "./globalTypes";

// ====================================================
// GraphQL mutation operation: CreateBudgetAllocation
// ====================================================

export interface CreateBudgetAllocation_createBudgetAllocation_result_budget {
  __typename: "Budget";
  id: string;
  name: string;
}

export interface CreateBudgetAllocation_createBudgetAllocation_result_transaction {
  __typename: "Transaction";
  id: string;
}

export interface CreateBudgetAllocation_createBudgetAllocation_result {
  __typename: "BudgetAllocation";
  id: string;
  amount: Decimal;
  budget: CreateBudgetAllocation_createBudgetAllocation_result_budget;
  transaction: CreateBudgetAllocation_createBudgetAllocation_result_transaction;
}

export interface CreateBudgetAllocation_createBudgetAllocation {
  __typename: "CreateBudgetAllocationResult";
  /**
   * The successful result of the mutation
   */
  result: CreateBudgetAllocation_createBudgetAllocation_result | null;
}

export interface CreateBudgetAllocation {
  createBudgetAllocation: CreateBudgetAllocation_createBudgetAllocation | null;
}

export interface CreateBudgetAllocationVariables {
  input?: CreateBudgetAllocationInput | null;
}
