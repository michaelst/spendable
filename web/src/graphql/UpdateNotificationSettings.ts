/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

import { UpdateNotificationSettingsInput } from "./globalTypes";

// ====================================================
// GraphQL mutation operation: UpdateNotificationSettings
// ====================================================

export interface UpdateNotificationSettings_updateNotificationSettings_result {
  __typename: "NotificationSettings";
  id: string;
  enabled: boolean;
}

export interface UpdateNotificationSettings_updateNotificationSettings {
  __typename: "UpdateNotificationSettingsResult";
  /**
   * The successful result of the mutation
   */
  result: UpdateNotificationSettings_updateNotificationSettings_result | null;
}

export interface UpdateNotificationSettings {
  updateNotificationSettings: UpdateNotificationSettings_updateNotificationSettings | null;
}

export interface UpdateNotificationSettingsVariables {
  id: string;
  input?: UpdateNotificationSettingsInput | null;
}
