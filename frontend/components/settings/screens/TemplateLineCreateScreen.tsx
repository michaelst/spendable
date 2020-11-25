import React, { useLayoutEffect, useState } from 'react'
import { Text, View, } from 'react-native'
import { TouchableWithoutFeedback } from 'react-native-gesture-handler'
import { RouteProp, useRoute, useNavigation } from '@react-navigation/native'
import { useQuery, useMutation } from '@apollo/client'

import { RootStackParamList } from 'components/settings/Settings'
import { CREATE_TEMPLATE_LINE, GET_TEMPLATE } from 'components/settings/queries'
import { LIST_BUDGETS } from 'components/budgets/queries'
import { ListBudgets } from 'components/budgets/graphql/ListBudgets'
import { GetAllocationTemplate } from '../graphql/GetAllocationTemplate'
import AppStyles from 'constants/AppStyles'
import FormInput from 'components/shared/screen/form/FormInput'
import BudgetSelect from 'components/shared/screen/form/BudgetSelect'

export default function TemplateLineCreateScreen() {
  const { styles } = AppStyles()

  const navigation = useNavigation()
  const route = useRoute<RouteProp<RootStackParamList, 'Create Template Line'>>()
  const { templateId } = route.params

  const [amount, setAmount] = useState('')
  const [budgetId, setBudgetId] = useState('')

  const budgetQuery = useQuery<ListBudgets>(LIST_BUDGETS)
  const budgetName = budgetQuery.data?.budgets.find(b => b.id === budgetId)?.name ?? ''

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