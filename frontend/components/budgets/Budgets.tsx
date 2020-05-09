import React from 'react'
import { createStackNavigator } from '@react-navigation/stack'
import BudgetsScreen from './screens/budgets-screen/BudgetsScreen'
import BudgetScreen from './screens/budget-screen/BudgetScreen'

export type RootStackParamList = {
  Budgets: undefined,
  Budget: { budgetId: string }
}

const Stack = createStackNavigator()

export default function Budgets() {
  return (
    <Stack.Navigator>
      <Stack.Screen name="Budgets" component={BudgetsScreen} />
      <Stack.Screen name="Budget" component={BudgetScreen} />
    </Stack.Navigator>
  )
}