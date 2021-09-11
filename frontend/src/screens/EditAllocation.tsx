import React, { useLayoutEffect, useState } from 'react'
import { View, } from 'react-native'
import { RouteProp, useRoute, useNavigation } from '@react-navigation/native'
import { useQuery, useMutation } from '@apollo/client'
import FormInput from 'src/components/FormInput'
import BudgetSelect from 'src/components/BudgetSelect'
import { GET_ALLOCATION, MAIN_QUERY, UPDATE_ALLOCATION } from '../queries'
import { Allocation } from '../graphql/Allocation'
import HeaderButton from 'src/components/HeaderButton'
import { Main } from 'src/graphql/Main'

const EditAllocation = () => {
  const navigation = useNavigation<NavigationProp>()
  const { params: { allocationId } } = useRoute<RouteProp<RootStackParamList, 'Edit Allocation'>>()

  const [amount, setAmount] = useState('')
  const [budgetId, setBudgetId] = useState('')

  useQuery<Allocation>(GET_ALLOCATION, {
    variables: { id: allocationId },
    onCompleted: data => {
      setAmount(data.allocation.amount.toDecimalPlaces(2).toFixed(2))
      setBudgetId(data.allocation.budget.id)
    }
  })

  const { data } = useQuery<Main>(MAIN_QUERY)
  const budgetName = data?.budgets.find(b => b.id === budgetId)?.name ?? ''

  const [updateAllocation] = useMutation(UPDATE_ALLOCATION, {
    variables: {
      id: allocationId,
      amount: amount,
      budgetId: budgetId,
    },
    refetchQueries: [{ query: MAIN_QUERY }]
  })

  const saveAndGoBack = () => {
    updateAllocation()
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

export default EditAllocation