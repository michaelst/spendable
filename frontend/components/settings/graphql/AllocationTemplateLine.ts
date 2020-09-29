/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL query operation: AllocationTemplateLine
// ====================================================

export interface AllocationTemplateLine_allocationTemplateLine_budget {
  __typename: "Budget";
  id: string;
}

export interface AllocationTemplateLine_allocationTemplateLine_allocationTemplate {
  __typename: "AllocationTemplate";
  id: string;
}

export interface AllocationTemplateLine_allocationTemplateLine {
  __typename: "AllocationTemplateLine";
  id: string;
  amount: Decimal;
  budget: AllocationTemplateLine_allocationTemplateLine_budget;
  allocationTemplate: AllocationTemplateLine_allocationTemplateLine_allocationTemplate;
}

export interface AllocationTemplateLine {
  allocationTemplateLine: AllocationTemplateLine_allocationTemplateLine;
}

export interface AllocationTemplateLineVariables {
  id: string;
}
