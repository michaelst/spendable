/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

import { RegisterDeviceTokenInput } from "./globalTypes";

// ====================================================
// GraphQL mutation operation: RegisterDeviceToken
// ====================================================

export interface RegisterDeviceToken_registerDeviceToken_result {
  __typename: "NotificationSettings";
  id: string;
  enabled: boolean;
}

export interface RegisterDeviceToken_registerDeviceToken {
  __typename: "RegisterDeviceTokenResult";
  /**
   * The successful result of the mutation
   */
  result: RegisterDeviceToken_registerDeviceToken_result | null;
}

export interface RegisterDeviceToken {
  registerDeviceToken: RegisterDeviceToken_registerDeviceToken | null;
}

export interface RegisterDeviceTokenVariables {
  input?: RegisterDeviceTokenInput | null;
}
