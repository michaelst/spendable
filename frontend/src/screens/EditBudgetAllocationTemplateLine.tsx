import React, { useLayoutEffect, useState } from 'react'
import { View, } from 'react-native'
import { RouteProp, useRoute, useNavigation } from '@react-navigation/native'
import { useQuery, useMutation } from '@apollo/client'
import FormInput from 'src/components/FormInput'
import BudgetSelect from 'src/components/BudgetSelect'
import { GET_BUDGET_ALLOCATION_TEMPLATE_LINE, MAIN_QUERY, UPDATE_BUDGET_ALLOCATION_TEMPLATE_LINE } from 'src/queries'
import { Main } from 'src/graphql/Main'
import HeaderButton from 'src/components/HeaderButton'
import { BudgetAllocationTemplateLine } from 'src/graphql/BudgetAllocationTemplateLine'

const EditBudgetAllocationTemplateLine = () => {
  const navigation = useNavigation<NavigationProp>()
  const { params: { lineId } } = useRoute<RouteProp<RootStackParamList, 'Edit Template Line'>>()

  const [amount, setAmount] = useState('')
  const [budgetId, setBudgetId] = useState('')

  useQuery<BudgetAllocationTemplateLine>(GET_BUDGET_ALLOCATION_TEMPLATE_LINE, {
    variables: { id: lineId },
    onCompleted: data => {
      setAmount(data.budgetAllocationTemplateLine.amount.toDecimalPlaces(2).toFixed(2))
      setBudgetId(data.budgetAllocationTemplateLine.budget.id)
    }
  })

  const { data } = useQuery<Main>(MAIN_QUERY)
  const budgetName = data?.budgets.find(b => b.id === budgetId)?.name ?? ''

  const [updateTemplateLine] = useMutation(UPDATE_BUDGET_ALLOCATION_TEMPLATE_LINE, {
    variables: {
      id: lineId,
      amount: amount,
      budgetId: budgetId
    }
  })

  const saveAndGoBack = () => {
    updateTemplateLine()
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

export default EditBudgetAllocationTemplateLine