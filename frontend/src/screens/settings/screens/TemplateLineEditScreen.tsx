import React, { useLayoutEffect, useState } from 'react'
import { View, } from 'react-native'
import { RouteProp, useRoute, useNavigation } from '@react-navigation/native'
import { useQuery, useMutation } from '@apollo/client'
import { GET_TEMPLATE_LINE, UPDATE_TEMPLATE_LINE } from 'src/screens/settings/queries'
import { AllocationTemplateLine } from 'src/screens/settings/graphql/AllocationTemplateLine'
import FormInput from 'src/components/FormInput'
import BudgetSelect from 'src/components/BudgetSelect'
import { MAIN_QUERY } from 'src/queries'
import { Main } from 'src/graphql/Main'
import HeaderButton from 'src/components/HeaderButton'

export default function TemplateLineEditScreen() {
  const navigation = useNavigation<NavigationProp>()
  const { params: { lineId } } = useRoute<RouteProp<RootStackParamList, 'Edit Template Line'>>()

  const [amount, setAmount] = useState('')
  const [budgetId, setBudgetId] = useState('')

  const { data } = useQuery<AllocationTemplateLine>(GET_TEMPLATE_LINE, {
    variables: { id: lineId },
    onCompleted: data => {
      setAmount(data.allocationTemplateLine.amount.toDecimalPlaces(2).toFixed(2))
      setBudgetId(data.allocationTemplateLine.budget.id)
    }
  })

  const { data: budgetData } = useQuery<Main>(MAIN_QUERY)
  const budgetName = budgetData?.budgets.find(b => b.id === budgetId)?.name ?? ''

  const [updateTemplateLine] = useMutation(UPDATE_TEMPLATE_LINE, {
    variables: {
      id: lineId,
      amount: amount,
      budgetId: budgetId
    }
  })

  const navigateToTemplate = () => navigation.navigate('Template', { templateId: data?.allocationTemplateLine.allocationTemplate.id })
  const saveAndGoBack = () => {
    updateTemplateLine()
    navigateToTemplate()
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