/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL mutation operation: UpdateAllocationTemplateLine
// ====================================================

export interface UpdateAllocationTemplateLine_updateAllocationTemplateLine_budget {
  __typename: "Budget";
  id: string;
}

export interface UpdateAllocationTemplateLine_updateAllocationTemplateLine_allocationTemplate {
  __typename: "AllocationTemplate";
  id: string;
}

export interface UpdateAllocationTemplateLine_updateAllocationTemplateLine {
  __typename: "AllocationTemplateLine";
  id: string;
  amount: Decimal;
  budget: UpdateAllocationTemplateLine_updateAllocationTemplateLine_budget;
  allocationTemplate: UpdateAllocationTemplateLine_updateAllocationTemplateLine_allocationTemplate;
}

export interface UpdateAllocationTemplateLine {
  updateAllocationTemplateLine: UpdateAllocationTemplateLine_updateAllocationTemplateLine | null;
}

export interface UpdateAllocationTemplateLineVariables {
  id: string;
  budgetAllocationTemplateId?: string | null;
  amount?: Decimal | null;
  budgetId?: string | null;
}
