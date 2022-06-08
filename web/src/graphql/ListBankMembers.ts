/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL query operation: ListBankMembers
// ====================================================

export interface ListBankMembers_bankMembers_bankAccounts {
  __typename: "BankAccount";
  id: string;
  name: string;
  sync: boolean;
  balance: Decimal;
}

export interface ListBankMembers_bankMembers {
  __typename: "BankMember";
  id: string;
  name: string;
  status: string | null;
  logo: string | null;
  bankAccounts: ListBankMembers_bankMembers_bankAccounts[];
}

export interface ListBankMembers {
  bankMembers: ListBankMembers_bankMembers[];
}
