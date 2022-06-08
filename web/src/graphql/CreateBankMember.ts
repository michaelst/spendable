/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

import { CreateBankMemberInput } from "./globalTypes";

// ====================================================
// GraphQL mutation operation: CreateBankMember
// ====================================================

export interface CreateBankMember_createBankMember_result {
  __typename: "BankMember";
  id: string;
  name: string;
  status: string | null;
  logo: string | null;
}

export interface CreateBankMember_createBankMember {
  __typename: "CreateBankMemberResult";
  /**
   * The successful result of the mutation
   */
  result: CreateBankMember_createBankMember_result | null;
}

export interface CreateBankMember {
  createBankMember: CreateBankMember_createBankMember | null;
}

export interface CreateBankMemberVariables {
  input?: CreateBankMemberInput | null;
}
