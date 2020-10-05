import React from 'react'
import { createStackNavigator } from '@react-navigation/stack'
import SettingsScreen from './screens/SettingsScreen'
import BankMembersScreen from './screens/BankMembersScreen'
import BankMemberScreen from './screens/BankMemberScreen'
import TemplatesScreen from './screens/TemplatesScreen'
import TemplateScreen from './screens/TemplateScreen'
import TemplateCreateScreen from './screens/TemplateCreateScreen'
import TemplateEditScreen from './screens/TemplateEditScreen'
import TemplateLineCreateScreen from './screens/TemplateLineCreateScreen'
import TemplateLineEditScreen from './screens/TemplateLineEditScreen'

export type RootStackParamList = {
  Settings: undefined,
  Banks: undefined,
  Bank: { bankMemberId: string },
  Templates: undefined,
  Template: { templateId: string },
  'Create Template': undefined
  'Edit Template': { templateId: string }
  'Create Template Line': { templateId: string },
  'Edit Template Line': { lineId: string }
}

const Stack = createStackNavigator()

export default function Budgets() {
  return (
    <Stack.Navigator>
      <Stack.Screen name="Settings" component={SettingsScreen} options={options} />
      <Stack.Screen name="Banks" component={BankMembersScreen} options={options} />
      <Stack.Screen name="Bank" component={BankMemberScreen} options={options} />
      <Stack.Screen name="Templates" component={TemplatesScreen} options={options} />
      <Stack.Screen name="Template" component={TemplateScreen} options={options} />
      <Stack.Screen name="Create Template" component={TemplateCreateScreen} options={options} />
      <Stack.Screen name="Edit Template" component={TemplateEditScreen} options={options} />
      <Stack.Screen name="Create Template Line" component={TemplateLineCreateScreen} options={options} />
      <Stack.Screen name="Edit Template Line" component={TemplateLineEditScreen} options={options} />
    </Stack.Navigator>
  )
}

const options = {
  headerTitleStyle: { fontSize: 18 },
  headerBackAllowFontScaling: true,
  headerBackTitleStyle: {
    fontSize: 18
  }
}