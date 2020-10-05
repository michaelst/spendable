/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL query operation: ListAllocationTemplates
// ====================================================

export interface ListAllocationTemplates_allocationTemplates_lines {
  __typename: "AllocationTemplateLine";
  amount: Decimal;
}

export interface ListAllocationTemplates_allocationTemplates {
  __typename: "AllocationTemplate";
  id: string;
  name: string;
  lines: ListAllocationTemplates_allocationTemplates_lines[];
}

export interface ListAllocationTemplates {
  allocationTemplates: ListAllocationTemplates_allocationTemplates[];
}
