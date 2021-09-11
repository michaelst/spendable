/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL query operation: GetBankMember
// ====================================================

export interface GetBankMember_bankMember_bankAccounts {
  __typename: "BankAccount";
  id: string;
  name: string;
  sync: boolean;
  balance: Decimal;
}

export interface GetBankMember_bankMember {
  __typename: "BankMember";
  id: string;
  name: string;
  status: string | null;
  logo: string | null;
  bankAccounts: GetBankMember_bankMember_bankAccounts[];
}

export interface GetBankMember {
  bankMember: GetBankMember_bankMember;
}

export interface GetBankMemberVariables {
  id: string;
}
