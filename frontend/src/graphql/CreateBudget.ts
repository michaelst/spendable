/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

import { CreateBudgetInput } from "./globalTypes";

// ====================================================
// GraphQL mutation operation: CreateBudget
// ====================================================

export interface CreateBudget_createBudget_result {
  __typename: "Budget";
  id: string;
  name: string;
  balance: Decimal;
}

export interface CreateBudget_createBudget {
  __typename: "CreateBudgetResult";
  /**
   * The successful result of the mutation
   */
  result: CreateBudget_createBudget_result | null;
}

export interface CreateBudget {
  createBudget: CreateBudget_createBudget | null;
}

export interface CreateBudgetVariables {
  input?: CreateBudgetInput | null;
}
