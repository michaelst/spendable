/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL mutation operation: SignInWithApple
// ====================================================

export interface SignInWithApple_signInWithApple {
  __typename: "User";
  token: string | null;
}

export interface SignInWithApple {
  signInWithApple: SignInWithApple_signInWithApple | null;
}

export interface SignInWithAppleVariables {
  token: string;
}
