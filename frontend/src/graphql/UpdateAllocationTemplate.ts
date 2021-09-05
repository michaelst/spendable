/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

import { AllocationTemplateLineInputObject } from "./globalTypes";

// ====================================================
// GraphQL mutation operation: UpdateAllocationTemplate
// ====================================================

export interface UpdateAllocationTemplate_updateAllocationTemplate_lines_budget {
  __typename: "Budget";
  id: string;
}

export interface UpdateAllocationTemplate_updateAllocationTemplate_lines {
  __typename: "AllocationTemplateLine";
  id: string;
  amount: Decimal;
  budget: UpdateAllocationTemplate_updateAllocationTemplate_lines_budget;
}

export interface UpdateAllocationTemplate_updateAllocationTemplate {
  __typename: "AllocationTemplate";
  id: string;
  name: string;
  lines: UpdateAllocationTemplate_updateAllocationTemplate_lines[];
}

export interface UpdateAllocationTemplate {
  updateAllocationTemplate: UpdateAllocationTemplate_updateAllocationTemplate | null;
}

export interface UpdateAllocationTemplateVariables {
  id: string;
  name: string;
  lines?: (AllocationTemplateLineInputObject | null)[] | null;
}
