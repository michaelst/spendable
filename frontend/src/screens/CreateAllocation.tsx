import React, { useLayoutEffect, useState } from 'react'
import { View, } from 'react-native'
import { RouteProp, useRoute, useNavigation } from '@react-navigation/native'
import { useQuery, useMutation } from '@apollo/client'
import FormInput from 'src/components/FormInput'
import BudgetSelect from 'src/components/BudgetSelect'
import { RootStackParamList } from 'src/screens/transactions/Transactions'
import { CREATE_ALLOCATION, GET_TRANSACTION, MAIN_QUERY } from '../queries'
import { Main } from 'src/graphql/Main'
import HeaderButton from 'src/components/HeaderButton'

export default function AllocationCreateScreen() {
  const navigation = useNavigation<NavigationProp>()
  const { params: { transactionId } } = useRoute<RouteProp<RootStackParamList, 'Create Allocation'>>()

  const [amount, setAmount] = useState('')
  const [budgetId, setBudgetId] = useState('')

  const { data } = useQuery<Main>(MAIN_QUERY)
  const budgetName = data?.budgets.find(b => b.id === budgetId)?.name ?? ''

  const [createAllocation] = useMutation(CREATE_ALLOCATION, {
    variables: {
      amount: amount,
      budgetId: budgetId,
      transactionId: transactionId,
    },
    refetchQueries: [{ query: MAIN_QUERY }, { query: GET_TRANSACTION, variables: { id: transactionId } }]
  })

  const navigateToSpendFrom = () => navigation.navigate('Spend From', { transactionId: transactionId })
  const saveAndGoBack = () => {
    createAllocation()
    navigateToSpendFrom()
  }

  useLayoutEffect(() => navigation.setOptions({ 
    headerTitle: '', 
    headerRight: <HeaderButton onPress={saveAndGoBack} title="Save" /> 
  }))

  return (
    <View>
      <FormInput title='Amount' value={amount} setValue={setAmount} keyboardType='decimal-pad' />
      <BudgetSelect title='Expense/Goal' value={budgetName} setValue={setBudgetId} />
    </View>
  )
}