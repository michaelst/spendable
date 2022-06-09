/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL query operation: Main
// ====================================================

export interface Main_currentUser_spentByMonth {
  __typename: "MonthSpend";
  month: Date;
  spent: Decimal;
}

export interface Main_currentUser {
  __typename: "User";
  id: string;
  spendable: Decimal;
  spentByMonth: Main_currentUser_spentByMonth[];
}

export interface Main_budgets {
  __typename: "Budget";
  id: string;
  name: string;
  balance: Decimal;
  trackSpendingOnly: boolean;
  archivedAt: NaiveDateTime | null;
  spent: Decimal;
}

export interface Main {
  currentUser: Main_currentUser;
  budgets: Main_budgets[];
}

export interface MainVariables {
  month: Date;
}
