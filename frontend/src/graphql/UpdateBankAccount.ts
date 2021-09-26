/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

import { UpdateBankAccountInput } from "./globalTypes";

// ====================================================
// GraphQL mutation operation: UpdateBankAccount
// ====================================================

export interface UpdateBankAccount_updateBankAccount_result {
  __typename: "BankAccount";
  id: string;
  sync: boolean;
}

export interface UpdateBankAccount_updateBankAccount {
  __typename: "UpdateBankAccountResult";
  /**
   * The successful result of the mutation
   */
  result: UpdateBankAccount_updateBankAccount_result | null;
}

export interface UpdateBankAccount {
  updateBankAccount: UpdateBankAccount_updateBankAccount | null;
}

export interface UpdateBankAccountVariables {
  id: string;
  input?: UpdateBankAccountInput | null;
}
