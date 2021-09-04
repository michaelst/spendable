/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL mutation operation: UpdateAllocation
// ====================================================

export interface UpdateAllocation_updateAllocation_budget {
  __typename: "Budget";
  id: string;
  name: string;
}

export interface UpdateAllocation_updateAllocation {
  __typename: "Allocation";
  id: string;
  amount: Decimal;
  budget: UpdateAllocation_updateAllocation_budget;
}

export interface UpdateAllocation {
  updateAllocation: UpdateAllocation_updateAllocation;
}

export interface UpdateAllocationVariables {
  id: string;
  amount?: Decimal | null;
  budgetId?: string | null;
}
