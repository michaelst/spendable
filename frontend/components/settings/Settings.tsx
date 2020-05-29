import React from 'react'
import { createStackNavigator } from '@react-navigation/stack'
import SettingsScreen from './screens/SettingsScreen'
import BankMembersScreen from './screens/BankMembersScreen'
import BankMemberScreen from './screens/BankMemberScreen'

export type RootStackParamList = {
  Settings: undefined,
  Banks: undefined,
  Bank: { bankMemberId: string },
  Templates: undefined,
}

const Stack = createStackNavigator()

export default function Budgets() {
  return (
    <Stack.Navigator>
      <Stack.Screen name="Settings" component={SettingsScreen} />
      <Stack.Screen name="Banks" component={BankMembersScreen} />
      <Stack.Screen name="Bank" component={BankMemberScreen} />
    </Stack.Navigator>
  )
}