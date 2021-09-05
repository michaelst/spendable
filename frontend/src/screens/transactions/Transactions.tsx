import React from 'react'
import { createStackNavigator } from '@react-navigation/stack'
import TransactionsScreen from './screens/TransactionsScreen'

import AppStyles from 'src/utils/useAppStyles'
import TransactionScreen from './screens/TransactionScreen'
import TransactionCreateScreen from './screens/TransactionCreateScreen'
import SpendFromScreen from './screens/SpendFromScreen'
import AllocationCreateScreen from './screens/AllocationCreateScreen'
import AllocationEditScreen from './screens/AllocationEditScreen'

export type RootStackParamList = {
  Transactions: undefined,
  Transaction: { transactionId: string },
  'Create Transaction': undefined,
  'Spend From': { transactionId: string },
  'Create Allocation': { transactionId: string },
  'Edit Allocation': { allocationId: string, transactionId: string },
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
      <Stack.Screen name="Transactions" component={TransactionsScreen} options={options} />
      <Stack.Screen name="Transaction" component={TransactionScreen} options={options} />
      <Stack.Screen name="Create Transaction" component={TransactionCreateScreen} options={options} />
      <Stack.Screen name="Spend From" component={SpendFromScreen} options={options} />
      <Stack.Screen name="Create Allocation" component={AllocationCreateScreen} options={options} />
      <Stack.Screen name="Edit Allocation" component={AllocationEditScreen} options={options} />
    </Stack.Navigator>
  )
}