/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

//==============================================================
// START Enums and Input Objects
//==============================================================

export interface CreateBankMemberInput {
  publicToken: string;
}

export interface CreateBudgetAllocationBudgetInput {
  id?: number | null;
}

export interface CreateBudgetAllocationInput {
  amount: Decimal;
  budget?: CreateBudgetAllocationBudgetInput | null;
  transaction?: CreateBudgetAllocationTransactionInput | null;
}

export interface CreateBudgetAllocationTemplateBudgetAllocationTemplateLinesInput {
  amount?: Decimal | null;
  budget?: CreateBudgetAllocationTemplateLineBudgetInput | null;
  budgetAllocationTemplate?: CreateBudgetAllocationTemplateLineBudgetAllocationTemplateInput | null;
}

export interface CreateBudgetAllocationTemplateInput {
  budgetAllocationTemplateLines?: CreateBudgetAllocationTemplateBudgetAllocationTemplateLinesInput[] | null;
  name: string;
}

export interface CreateBudgetAllocationTemplateLineBudgetAllocationTemplateInput {
  id?: number | null;
}

export interface CreateBudgetAllocationTemplateLineBudgetInput {
  id?: number | null;
}

export interface CreateBudgetAllocationTemplateLineInput {
  amount: Decimal;
  budget?: CreateBudgetAllocationTemplateLineBudgetInput | null;
  budgetAllocationTemplate?: CreateBudgetAllocationTemplateLineBudgetAllocationTemplateInput | null;
}

export interface CreateBudgetAllocationTransactionInput {
  id?: number | null;
}

export interface CreateBudgetInput {
  adjustment?: Decimal | null;
  name: string;
}

export interface CreateTransactionBudgetAllocationsInput {
  amount?: Decimal | null;
  budget?: CreateBudgetAllocationBudgetInput | null;
  transaction?: CreateBudgetAllocationTransactionInput | null;
}

export interface CreateTransactionInput {
  amount: Decimal;
  budgetAllocations?: CreateTransactionBudgetAllocationsInput[] | null;
  date: Date;
  name: string;
  note?: string | null;
  reviewed: boolean;
}

export interface UpdateBankAccountInput {
  sync?: boolean | null;
}

export interface UpdateBudgetAllocationBudgetInput {
  id?: number | null;
}

export interface UpdateBudgetAllocationInput {
  amount?: Decimal | null;
  budget?: UpdateBudgetAllocationBudgetInput | null;
}

export interface UpdateBudgetAllocationTemplateBudgetAllocationTemplateLinesInput {
  amount?: Decimal | null;
  budget?: UpdateBudgetAllocationTemplateLineBudgetInput | null;
  budgetAllocationTemplate?: UpdateBudgetAllocationTemplateLineBudgetAllocationTemplateInput | null;
}

export interface UpdateBudgetAllocationTemplateInput {
  budgetAllocationTemplateLines?: UpdateBudgetAllocationTemplateBudgetAllocationTemplateLinesInput[] | null;
  name?: string | null;
}

export interface UpdateBudgetAllocationTemplateLineBudgetAllocationTemplateInput {
  id?: number | null;
}

export interface UpdateBudgetAllocationTemplateLineBudgetInput {
  id?: number | null;
}

export interface UpdateBudgetAllocationTemplateLineInput {
  amount?: Decimal | null;
  budget?: UpdateBudgetAllocationTemplateLineBudgetInput | null;
  budgetAllocationTemplate?: UpdateBudgetAllocationTemplateLineBudgetAllocationTemplateInput | null;
}

export interface UpdateBudgetInput {
  adjustment?: Decimal | null;
  name?: string | null;
}

export interface UpdateNotificationSettingsInput {
  enabled?: boolean | null;
}

export interface UpdateTransactionBudgetAllocationsInput {
  amount?: Decimal | null;
  budget?: UpdateBudgetAllocationBudgetInput | null;
  transaction?: CreateBudgetAllocationTransactionInput | null;
}

export interface UpdateTransactionInput {
  amount?: Decimal | null;
  budgetAllocations?: UpdateTransactionBudgetAllocationsInput[] | null;
  date?: Date | null;
  name?: string | null;
  note?: string | null;
  reviewed?: boolean | null;
}

//==============================================================
// END Enums and Input Objects
//==============================================================
