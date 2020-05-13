import React from 'react'
import {
  View,
  Text
} from 'react-native'
import { createStackNavigator } from '@react-navigation/stack'
import { useTheme } from '@react-navigation/native'
import BudgetsScreen from './screens/budgets-screen/BudgetsScreen'
import BudgetScreen from './screens/budget-screen/BudgetScreen'
import BudgetEditScreen from './screens/budget-edit-screen/BudgetEditScreen'

export type RootStackParamList = {
  Budgets: undefined,
  Budget: { budgetId: string }
  'Edit Budget': { budgetId: string }
}

const Stack = createStackNavigator()

export default function Budgets() {
  const { colors }: any = useTheme()

  const spendableHeader = () => {
    return (
      <View style={{alignItems: 'center'}}>
        <Text style={{color: colors.text, fontWeight: 'bold', fontSize: 18}}>$100.00</Text>
        <Text style={{color: colors.secondary, fontSize: 12}}>Spendable</Text>
      </View>
    )
  }

  return (
    <Stack.Navigator>
      <Stack.Screen name="Budgets" component={BudgetsScreen} options={{ headerTitle: spendableHeader }} />
      <Stack.Screen name="Budget" component={BudgetScreen} />
      <Stack.Screen name="Edit Budget" component={BudgetEditScreen} />
    </Stack.Navigator>
  )
}