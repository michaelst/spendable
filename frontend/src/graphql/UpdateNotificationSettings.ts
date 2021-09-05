/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL mutation operation: UpdateNotificationSettings
// ====================================================

export interface UpdateNotificationSettings_updateNotificationSettings {
  __typename: "NotificationSettings";
  id: string;
  enabled: boolean;
}

export interface UpdateNotificationSettings {
  updateNotificationSettings: UpdateNotificationSettings_updateNotificationSettings;
}

export interface UpdateNotificationSettingsVariables {
  id: string;
  enabled: boolean;
}
