/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL query operation: ListBankMembers
// ====================================================

export interface ListBankMembers_bankMembers {
  __typename: "BankMember";
  id: string;
  name: string;
  status: string | null;
  logo: string | null;
}

export interface ListBankMembers {
  bankMembers: ListBankMembers_bankMembers[];
}
