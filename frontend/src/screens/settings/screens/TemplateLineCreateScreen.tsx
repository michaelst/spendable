import React, { useLayoutEffect, useState } from 'react'
import { View, } from 'react-native'
import { RouteProp, useRoute, useNavigation } from '@react-navigation/native'
import { useQuery, useMutation } from '@apollo/client'
import { CREATE_TEMPLATE_LINE, GET_TEMPLATE } from 'src/screens/settings/queries'
import { GetAllocationTemplate } from '../graphql/GetAllocationTemplate'
import FormInput from 'src/components/FormInput'
import BudgetSelect from 'src/components/BudgetSelect'
import { MAIN_QUERY } from 'src/queries'
import { Main } from 'src/graphql/Main'
import HeaderButton from 'src/components/HeaderButton'

export default function TemplateLineCreateScreen() {
  const navigation = useNavigation<NavigationProp>()
  const route = useRoute<RouteProp<RootStackParamList, 'Create Template Line'>>()
  const { templateId } = route.params

  const [amount, setAmount] = useState('')
  const [budgetId, setBudgetId] = useState('')

  const { data } = useQuery<Main>(MAIN_QUERY)
  const budgetName = data?.budgets.find(b => b.id === budgetId)?.name ?? ''

  const [createTemplateLine] = useMutation(CREATE_TEMPLATE_LINE, {
    variables: {
      budgetAllocationTemplateId: templateId,
      amount: amount,
      budgetId: budgetId
    },
    update(cache, { data: { createAllocationTemplateLine } }) {
      const data = cache.readQuery<GetAllocationTemplate | null>({ query: GET_TEMPLATE, variables: { id: templateId } })
      const lines = data?.allocationTemplate.lines.concat([createAllocationTemplateLine])

      cache.writeQuery({
        query: GET_TEMPLATE,
        data: { allocationTemplate: {...data?.allocationTemplate, ...{lines: lines}} }
      })
    }
  })

  const navigateToTemplate = () => navigation.navigate('Template', { templateId: templateId })
  const saveAndGoBack = () => {
    createTemplateLine()
    navigateToTemplate()
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