import React, { useState } from 'react'
import { View, } from 'react-native'
import { RouteProp, useRoute } from '@react-navigation/native'
import { useQuery, useMutation } from '@apollo/client'
import FormInput from 'src/components/FormInput'
import BudgetSelect from 'src/components/BudgetSelect'
import { GET_BUDGET_ALLOCATION, MAIN_QUERY, UPDATE_BUDGET_ALLOCATION } from '../queries'
import { Main } from 'src/graphql/Main'
import { BudgetAllocation } from 'src/graphql/BudgetAllocation'
import useSaveAndGoBack from 'src/utils/useSaveAndGoBack'

const EditBudgetAllocation = () => {
  const { params: { allocationId } } = useRoute<RouteProp<RootStackParamList, 'Edit Allocation'>>()

  const [amount, setAmount] = useState('')
  const [budgetId, setBudgetId] = useState('')

  useQuery<BudgetAllocation>(GET_BUDGET_ALLOCATION, {
    variables: { id: allocationId },
    onCompleted: data => {
      setAmount(data.budgetAllocation.amount.toDecimalPlaces(2).toFixed(2))
      setBudgetId(data.budgetAllocation.budget.id)
    }
  })

  const { data } = useQuery<Main>(MAIN_QUERY)
  const budgetName = data?.budgets.find(b => b.id === budgetId)?.name ?? ''

  const [updateAllocation] = useMutation(UPDATE_BUDGET_ALLOCATION, {
    variables: {
      id: allocationId,
      input: {
        amount: amount,
        budget: { id: parseInt(budgetId) },
      }
    },
    refetchQueries: [{ query: MAIN_QUERY }]
  })

  useSaveAndGoBack({ mutation: updateAllocation, action: "edit expense" })

  return (
    <View>
      <FormInput title='Amount' value={amount} setValue={setAmount} keyboardType='decimal-pad' />
      <BudgetSelect title='Expense/Goal' value={budgetName} setValue={setBudgetId} />
    </View>
  )
}

export default EditBudgetAllocation