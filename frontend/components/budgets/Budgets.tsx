import React from 'react'
import { createStackNavigator } from '@react-navigation/stack'
import BudgetsScreen from './screens/BudgetsScreen'
import BudgetScreen from './screens/BudgetScreen'
import BudgetCreateScreen from './screens/BudgetCreateScreen'
import BudgetEditScreen from './screens/BudgetEditScreen'
import SpendableHeader from 'components/headers/spendable-header/SpendableHeader'
import AppStyles from 'constants/AppStyles'

export type RootStackParamList = {
  Expenses: undefined,
  Expense: { budgetId: string },
  'Create Expense': undefined,
  'Edit Expense': { budgetId: string }
}

const Stack = createStackNavigator()

export default function Budgets() {
  const { fontSize } = AppStyles()

  const options = {
    headerTitleStyle: { fontSize: fontSize },
    headerBackAllowFontScaling: true,
    headerBackTitleStyle: {
      fontSize: fontSize
    }
  }
  return (
    <Stack.Navigator>
      <Stack.Screen name="Expenses" component={BudgetsScreen} options={{ ...options, ...{ headerTitle: () => <SpendableHeader /> } }} />
      <Stack.Screen name="Expense" component={BudgetScreen} options={options} />
      <Stack.Screen name="Create Expense" component={BudgetCreateScreen} options={options} />
      <Stack.Screen name="Edit Expense" component={BudgetEditScreen} options={options} />
    </Stack.Navigator>
  )
}