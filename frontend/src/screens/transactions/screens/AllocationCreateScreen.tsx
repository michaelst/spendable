import React, { useLayoutEffect, useState } from 'react'
import { Text, View, } from 'react-native'
import { TouchableWithoutFeedback } from 'react-native-gesture-handler'
import { RouteProp, useRoute, useNavigation } from '@react-navigation/native'
import { useQuery, useMutation } from '@apollo/client'

import { LIST_BUDGETS } from 'src/screens/budgets/queries'
import { ListBudgets } from 'src/screens/budgets/graphql/ListBudgets'
import AppStyles from 'src/utils/useAppStyles'
import FormInput from 'src/screens/shared/screen/form/FormInput'
import BudgetSelect from 'src/screens/shared/screen/form/BudgetSelect'
import { RootStackParamList } from 'src/screens/transactions/Transactions'
import { GetTransaction } from '../graphql/GetTransaction'
import { CREATE_ALLOCATION, GET_TRANSACTION } from '../queries'
import { GET_SPENDABLE } from 'src/screens/headers/spendable-header/queries'

export default function AllocationCreateScreen() {
  const { styles } = AppStyles()

  const navigation = useNavigation()
  const route = useRoute<RouteProp<RootStackParamList, 'Create Allocation'>>()
  const { transactionId } = route.params

  const [amount, setAmount] = useState('')
  const [budgetId, setBudgetId] = useState('')

  const budgetQuery = useQuery<ListBudgets>(LIST_BUDGETS)
  const budgetName = budgetQuery.data?.budgets.find(b => b.id === budgetId)?.name ?? ''

  const [createAllocation] = useMutation(CREATE_ALLOCATION, {
    variables: {
      amount: amount,
      budgetId: budgetId,
      transactionId: transactionId,
    },
    refetchQueries: [{ query: LIST_BUDGETS }, { query: GET_SPENDABLE }],
    update(cache, { data: { createAllocation } }) {
      const data = cache.readQuery<GetTransaction | null>({ query: GET_TRANSACTION, variables: { id: transactionId } })
      const allocations = data?.transaction.allocations.concat([createAllocation])

      cache.writeQuery({
        query: GET_TRANSACTION,
        data: { transaction: { ...data?.transaction, ...{ allocations: allocations } } }
      })
    }
  })

  const navigateToSpendFrom = () => navigation.navigate('Spend From', { transactionId: transactionId })
  const saveAndGoBack = () => {
    createAllocation()
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