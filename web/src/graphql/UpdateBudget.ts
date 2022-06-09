/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

import { UpdateBudgetInput } from "./globalTypes";

// ====================================================
// GraphQL mutation operation: UpdateBudget
// ====================================================

export interface UpdateBudget_updateBudget_result {
  __typename: "Budget";
  id: string;
  name: string;
  balance: Decimal;
  trackSpendingOnly: boolean;
  archivedAt: NaiveDateTime | null;
}

export interface UpdateBudget_updateBudget {
  __typename: "UpdateBudgetResult";
  /**
   * The successful result of the mutation
   */
  result: UpdateBudget_updateBudget_result | null;
}

export interface UpdateBudget {
  updateBudget: UpdateBudget_updateBudget | null;
}

export interface UpdateBudgetVariables {
  id: string;
  input?: UpdateBudgetInput | null;
}
