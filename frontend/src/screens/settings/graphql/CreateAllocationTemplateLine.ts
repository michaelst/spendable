/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL mutation operation: CreateAllocationTemplateLine
// ====================================================

export interface CreateAllocationTemplateLine_createAllocationTemplateLine_budget {
  __typename: "Budget";
  id: string;
}

export interface CreateAllocationTemplateLine_createAllocationTemplateLine_allocationTemplate {
  __typename: "AllocationTemplate";
  id: string;
}

export interface CreateAllocationTemplateLine_createAllocationTemplateLine {
  __typename: "AllocationTemplateLine";
  id: string;
  amount: Decimal;
  budget: CreateAllocationTemplateLine_createAllocationTemplateLine_budget;
  allocationTemplate: CreateAllocationTemplateLine_createAllocationTemplateLine_allocationTemplate;
}

export interface CreateAllocationTemplateLine {
  createAllocationTemplateLine: CreateAllocationTemplateLine_createAllocationTemplateLine | null;
}

export interface CreateAllocationTemplateLineVariables {
  budgetAllocationTemplateId: string;
  amount: Decimal;
  budgetId: string;
}
