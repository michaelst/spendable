/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

import { AllocationTemplateLineInputObject } from "./../../../graphql/globalTypes";

// ====================================================
// GraphQL mutation operation: CreateAllocationTemplate
// ====================================================

export interface CreateAllocationTemplate_createAllocationTemplate_lines_budget {
  __typename: "Budget";
  id: string;
}

export interface CreateAllocationTemplate_createAllocationTemplate_lines {
  __typename: "AllocationTemplateLine";
  id: string;
  amount: Decimal;
  budget: CreateAllocationTemplate_createAllocationTemplate_lines_budget;
}

export interface CreateAllocationTemplate_createAllocationTemplate {
  __typename: "AllocationTemplate";
  id: string;
  name: string;
  lines: CreateAllocationTemplate_createAllocationTemplate_lines[];
}

export interface CreateAllocationTemplate {
  createAllocationTemplate: CreateAllocationTemplate_createAllocationTemplate | null;
}

export interface CreateAllocationTemplateVariables {
  name: string;
  lines?: (AllocationTemplateLineInputObject | null)[] | null;
}
