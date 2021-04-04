/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL query operation: GetPlaidLinkToken
// ====================================================

export interface GetPlaidLinkToken_currentUser {
  __typename: "User";
  id: number;
  plaidLinkToken: string;
}

export interface GetPlaidLinkToken {
  currentUser: GetPlaidLinkToken_currentUser | null;
}
