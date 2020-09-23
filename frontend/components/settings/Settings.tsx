import React from 'react'
import { createStackNavigator } from '@react-navigation/stack'
import SettingsScreen from './screens/SettingsScreen'
import BankMembersScreen from './screens/BankMembersScreen'
import BankMemberScreen from './screens/BankMemberScreen'
import TemplatesScreen from './screens/TemplatesScreen'

export type RootStackParamList = {
  Settings: undefined,
  Banks: undefined,
  Bank: { bankMemberId: string },
  Templates: undefined,
  Template: { templateId: string },
}

const Stack = createStackNavigator()

export default function Budgets() {
  return (
    <Stack.Navigator>
      <Stack.Screen
        name="Settings"
        component={SettingsScreen}
        options={{
          headerTitleStyle: { fontSize: 18 },
          headerBackAllowFontScaling: true,
          headerBackTitleStyle: {
            fontSize: 18
          }
        }}
      />
      <Stack.Screen
        name="Banks"
        component={BankMembersScreen}
        options={{
          headerTitleStyle: { fontSize: 18 },
          headerBackAllowFontScaling: true,
          headerBackTitleStyle: {
            fontSize: 18
          }
        }}
      />
      <Stack.Screen
        name="Bank"
        component={BankMemberScreen}
        options={{
          headerTitleStyle: { fontSize: 18 },
          headerBackAllowFontScaling: true,
          headerBackTitleStyle: {
            fontSize: 18
          }
        }}
      />
      <Stack.Screen
        name="Templates"
        component={TemplatesScreen}
        options={{
          headerTitleStyle: { fontSize: 18 },
          headerBackAllowFontScaling: true,
          headerBackTitleStyle: {
            fontSize: 18
          }
        }}
      />
    </Stack.Navigator>
  )
}