import React, { useLayoutEffect, useState } from 'react'
import { View, } from 'react-native'
import { RouteProp, useRoute, useNavigation } from '@react-navigation/native'
import { useQuery, useMutation } from '@apollo/client'
import FormInput from 'src/components/FormInput'
import BudgetSelect from 'src/components/BudgetSelect'
import { CREATE_BUDGET_ALLOCATION_TEMPLATE_LINE, GET_BUDGET_ALLOCATION_TEMPLATE, MAIN_QUERY } from 'src/queries'
import { Main } from 'src/graphql/Main'
import HeaderButton from 'src/components/HeaderButton'
import { GetBudgetAllocationTemplate } from 'src/graphql/GetBudgetAllocationTemplate'

const CreateBudgetAllocationTemplateLine = () => {
  const navigation = useNavigation<NavigationProp>()
  const { params: { templateId } } = useRoute<RouteProp<RootStackParamList, 'Create Template Line'>>()

  const [amount, setAmount] = useState('')
  const [budgetId, setBudgetId] = useState('')

  const { data } = useQuery<Main>(MAIN_QUERY)
  const budgetName = data?.budgets.find(b => b.id === budgetId)?.name ?? ''

  const [createTemplateLine] = useMutation(CREATE_BUDGET_ALLOCATION_TEMPLATE_LINE, {
    variables: {
      budgetAllocationTemplateId: templateId,
      amount: amount,
      budgetId: budgetId
    },
    update(cache, { data: { createAllocationTemplateLine } }) {
      const data = cache.readQuery<GetBudgetAllocationTemplate | null>({ query: GET_BUDGET_ALLOCATION_TEMPLATE, variables: { id: templateId } })
      const lines = data?.budgetAllocationTemplate.budgetAllocationTemplateLines.concat([createAllocationTemplateLine])

      cache.writeQuery({
        query: GET_BUDGET_ALLOCATION_TEMPLATE,
        data: { budgetAllocationTemplate: { ...data?.budgetAllocationTemplate, ...{ budgetAllocationTemplateLines: lines } } }
      })
    }
  })

  const saveAndGoBack = () => {
    createTemplateLine()
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

export default CreateBudgetAllocationTemplateLine