/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL query operation: CurrentUser
// ====================================================

export interface CurrentUser_currentUser {
  __typename: "User";
  id: number;
  spendable: Decimal;
}

export interface CurrentUser {
  currentUser: CurrentUser_currentUser | null;
}
