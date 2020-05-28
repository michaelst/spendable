/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL mutation operation: CreateBankMember
// ====================================================

export interface CreateBankMember_createBankMember_bankAccounts {
  __typename: "BankAccount";
  id: string;
  name: string;
  sync: boolean;
  balance: Decimal;
}

export interface CreateBankMember_createBankMember {
  __typename: "BankMember";
  id: string;
  name: string;
  status: string | null;
  logo: string | null;
  bankAccounts: CreateBankMember_createBankMember_bankAccounts[];
}

export interface CreateBankMember {
  createBankMember: CreateBankMember_createBankMember;
}

export interface CreateBankMemberVariables {
  publicToken: string;
}
