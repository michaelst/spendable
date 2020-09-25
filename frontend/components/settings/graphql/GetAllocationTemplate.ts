/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL query operation: GetAllocationTemplate
// ====================================================

export interface GetAllocationTemplate_allocationTemplate_lines_budget {
  __typename: "Budget";
  id: string;
  name: string;
}

export interface GetAllocationTemplate_allocationTemplate_lines {
  __typename: "AllocationTemplateLine";
  id: string;
  amount: Decimal;
  budget: GetAllocationTemplate_allocationTemplate_lines_budget;
}

export interface GetAllocationTemplate_allocationTemplate {
  __typename: "AllocationTemplate";
  id: string;
  name: string;
  lines: GetAllocationTemplate_allocationTemplate_lines[];
}

export interface GetAllocationTemplate {
  allocationTemplate: GetAllocationTemplate_allocationTemplate;
}

export interface GetAllocationTemplateVariables {
  id: string;
}
