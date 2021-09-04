/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL query operation: MainScreen
// ====================================================

export interface MainScreen_currentUser {
  __typename: "User";
  id: string;
  spendable: Decimal;
}

export interface MainScreen_budgets {
  __typename: "Budget";
  id: string;
  name: string;
  balance: Decimal;
}

export interface MainScreen {
  currentUser: MainScreen_currentUser;
  budgets: MainScreen_budgets[];
}
