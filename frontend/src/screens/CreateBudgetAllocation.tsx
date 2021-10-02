import React, { useLayoutEffect, useState } from 'react'
import { View, } from 'react-native'
import { RouteProp, useRoute, useNavigation } from '@react-navigation/native'
import { useQuery, useMutation } from '@apollo/client'
import FormInput from 'src/components/FormInput'
import BudgetSelect from 'src/components/BudgetSelect'
import { CREATE_BUDGET_ALLOCATION, GET_TRANSACTION, MAIN_QUERY } from '../queries'
import { Main } from 'src/graphql/Main'
import HeaderButton from 'src/components/HeaderButton'

const CreateBudgetAllocation = () => {
  const navigation = useNavigation<NavigationProp>()
  const { params: { transactionId } } = useRoute<RouteProp<RootStackParamList, 'Create Allocation'>>()

  const [amount, setAmount] = useState('')
  const [budgetId, setBudgetId] = useState('')

  const { data } = useQuery<Main>(MAIN_QUERY)
  const budgetName = data?.budgets.find(b => b.id === budgetId)?.name ?? ''

  const [createAllocation] = useMutation(CREATE_BUDGET_ALLOCATION, {
    variables: {
      amount: amount,
      budgetId: budgetId,
      transactionId: transactionId,
    },
    refetchQueries: [{ query: MAIN_QUERY }, { query: GET_TRANSACTION, variables: { id: transactionId } }]
  })

  const saveAndGoBack = () => {
    createAllocation()
    navigation.goBack()
  }

  useLayoutEffect(() => navigation.setOptions({ 
    headerTitle: '', 
    headerRight: () => <HeaderButton onPress={saveAndGoBack} title="Save" /> 
  }))

  return (
    <View>
      <FormInput title='Amount' value={amount} setValue={setAmount} keyboardType='decimal-pad' />
      <BudgetSelect title='Expense/Goal' value={budgetName} setValue={setBudgetId} />
    </View>
  )
}

export default CreateBudgetAllocation