/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL mutation operation: UpdateBankAccount
// ====================================================

export interface UpdateBankAccount_updateBankAccount {
  __typename: "BankAccount";
  id: string;
  sync: boolean;
}

export interface UpdateBankAccount {
  updateBankAccount: UpdateBankAccount_updateBankAccount;
}

export interface UpdateBankAccountVariables {
  id: string;
  sync: boolean;
}
