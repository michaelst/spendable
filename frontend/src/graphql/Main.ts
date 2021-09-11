/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL query operation: Main
// ====================================================

export interface Main_currentUser {
  __typename: "User";
  id: string;
  spendable: Decimal;
}

export interface Main_budgets {
  __typename: "Budget";
  id: string;
  name: string;
  balance: Decimal;
}

export interface Main {
  currentUser: Main_currentUser;
  budgets: Main_budgets[];
}
