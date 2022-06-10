/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL query operation: SpentByMonth
// ====================================================

export interface SpentByMonth_currentUser_spentByMonth {
  __typename: "MonthSpend";
  month: Date;
  spent: Decimal;
}

export interface SpentByMonth_currentUser {
  __typename: "User";
  id: string;
  spentByMonth: SpentByMonth_currentUser_spentByMonth[];
}

export interface SpentByMonth {
  currentUser: SpentByMonth_currentUser;
}
