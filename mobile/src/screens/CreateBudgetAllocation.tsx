import React, { useState } from 'react'
import { View, } from 'react-native'
import { RouteProp, useRoute } from '@react-navigation/native'
import { useQuery, useMutation } from '@apollo/client'
import FormInput from 'src/components/FormInput'
import BudgetSelect from 'src/components/BudgetSelect'
import { CREATE_BUDGET_ALLOCATION, GET_TRANSACTION, MAIN_QUERY } from '../queries'
import { Main } from 'src/graphql/Main'
import useSaveAndGoBack from 'src/hooks/useSaveAndGoBack'

const CreateBudgetAllocation = () => {
  const { params: { transactionId } } = useRoute<RouteProp<RootStackParamList, 'Create Allocation'>>()

  const [amount, setAmount] = useState('')
  const [budgetId, setBudgetId] = useState('')

  const { data } = useQuery<Main>(MAIN_QUERY)
  const budgetName = data?.budgets.find(b => b.id === budgetId)?.name ?? ''

  const [createBudgetAllocation] = useMutation(CREATE_BUDGET_ALLOCATION, {
    variables: {
      input: {
        amount: amount,
        budget: { id: parseInt(budgetId) },
        transaction: { id: parseInt(transactionId) }
      }
    },
    refetchQueries: [{ query: MAIN_QUERY }, { query: GET_TRANSACTION, variables: { id: transactionId } }]
  })

  useSaveAndGoBack({ mutation: createBudgetAllocation, action: "add expense to transaction" })

  return (
    <View>
      <FormInput title='Amount' value={amount} setValue={setAmount} keyboardType='decimal-pad' />
      <BudgetSelect title='Expense/Goal' value={budgetName} setValue={setBudgetId} />
    </View>
  )
}

export default CreateBudgetAllocation