import React, { useLayoutEffect, useState } from 'react'
import { Text, View, } from 'react-native'
import { TouchableWithoutFeedback } from 'react-native-gesture-handler'
import { RouteProp, useRoute, useNavigation } from '@react-navigation/native'
import { useQuery, useMutation } from '@apollo/client'

import { LIST_BUDGETS } from 'src/screens/budgets/queries'
import { ListBudgets } from 'src/screens/budgets/graphql/ListBudgets'
import AppStyles from 'src/utils/useAppStyles'
import FormInput from 'src/components/FormInput'
import BudgetSelect from 'src/screens/BudgetSelect'
import { RootStackParamList } from 'src/screens/transactions/Transactions'
import { GET_ALLOCATION, UPDATE_ALLOCATION } from '../queries'
import { Allocation } from '../graphql/Allocation'
import { GET_SPENDABLE } from 'src/screens/headers/spendable-header/queries'

export default function AllocationEditScreen() {
  const { styles } = AppStyles()

  const navigation = useNavigation()
  const route = useRoute<RouteProp<RootStackParamList, 'Edit Allocation'>>()
  const { allocationId, transactionId } = route.params

  const [amount, setAmount] = useState('')
  const [budgetId, setBudgetId] = useState('')

  useQuery<Allocation>(GET_ALLOCATION, {
    variables: { id: allocationId },
    onCompleted: data => {
      setAmount(data.allocation.amount.toDecimalPlaces(2).toFixed(2))
      setBudgetId(data.allocation.budget.id)
    }
  })

  const budgetQuery = useQuery<ListBudgets>(LIST_BUDGETS)
  const budgetName = budgetQuery.data?.budgets.find(b => b.id === budgetId)?.name ?? ''

  const [updateAllocation] = useMutation(UPDATE_ALLOCATION, {
    variables: {
      id: allocationId,
      amount: amount,
      budgetId: budgetId,
    },
    refetchQueries: [{ query: LIST_BUDGETS }, { query: GET_SPENDABLE }]
  })

  const navigateToSpendFrom = () => navigation.navigate('Spend From', { transactionId: transactionId })
  const saveAndGoBack = () => {
    updateAllocation()
    navigateToSpendFrom()
  }

  const headerRight = () => {
    return (
      <TouchableWithoutFeedback onPress={saveAndGoBack}>
        <Text style={styles.headerButtonText}>Save</Text>
      </TouchableWithoutFeedback>
    )
  }

  useLayoutEffect(() => navigation.setOptions({ headerTitle: '', headerRight: headerRight }))

  return (
    <View>
      <FormInput title='Amount' value={amount} setValue={setAmount} keyboardType='decimal-pad' />
      <BudgetSelect title='Expense/Goal' value={budgetName} setValue={setBudgetId} />
    </View>
  )
}