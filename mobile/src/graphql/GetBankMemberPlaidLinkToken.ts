/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL query operation: GetBankMemberPlaidLinkToken
// ====================================================

export interface GetBankMemberPlaidLinkToken_bankMember {
  __typename: "BankMember";
  id: string;
  plaidLinkToken: string;
}

export interface GetBankMemberPlaidLinkToken {
  bankMember: GetBankMemberPlaidLinkToken_bankMember;
}

export interface GetBankMemberPlaidLinkTokenVariables {
  id: string;
}
