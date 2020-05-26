import React from 'react'
import { createStackNavigator } from '@react-navigation/stack'
import BudgetsScreen from './screens/budgets-screen/BudgetsScreen'
import BudgetScreen from './screens/budget-screen/BudgetScreen'
import BudgetEditScreen from './screens/budget-edit-screen/BudgetEditScreen'
import SpendableHeader from 'components/headers/spendable-header/SpendableHeader'

export type RootStackParamList = {
  Budgets: undefined,
  Budget: { budgetId: string }
  'Edit Budget': { budgetId: string }
}

const Stack = createStackNavigator()

export default function Budgets() {
  return (
    <Stack.Navigator>
      <Stack.Screen name="Budgets" component={BudgetsScreen} options={{ headerTitle: () => <SpendableHeader /> }} />
      <Stack.Screen name="Budget" component={BudgetScreen} />
      <Stack.Screen name="Edit Budget" component={BudgetEditScreen} />
    </Stack.Navigator>
  )
}