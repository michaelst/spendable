/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL query operation: GetNotificationSettings
// ====================================================

export interface GetNotificationSettings_notificationSettings {
  __typename: "NotificationSettings";
  id: string;
  enabled: boolean;
}

export interface GetNotificationSettings {
  notificationSettings: GetNotificationSettings_notificationSettings;
}

export interface GetNotificationSettingsVariables {
  deviceToken: string;
}
