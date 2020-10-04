import React, { useState } from 'react'
import { RouteProp, useRoute, useNavigation } from '@react-navigation/native'
import { useQuery, useMutation } from '@apollo/client'
import { RootStackParamList } from 'components/settings/Settings'
import { GET_TEMPLATE_LINE, UPDATE_TEMPLATE_LINE } from 'components/settings/queries'
import { AllocationTemplateLine } from 'components/settings/graphql/AllocationTemplateLine'
import FormScreen, { FormField, FormFieldType } from 'components/shared/screen/form/FormScreen'
import { LIST_BUDGETS } from 'components/budgets/queries'
import { ListBudgets } from 'components/budgets/graphql/ListBudgets'

export default function TemplateLineEditScreen() {
  const navigation = useNavigation()
  const route = useRoute<RouteProp<RootStackParamList, 'Edit Template Line'>>()
  const { lineId } = route.params

  const [amount, setAmount] = useState('')
  const [budgetId, setBudgetId] = useState('')

  const { data } = useQuery<AllocationTemplateLine>(GET_TEMPLATE_LINE, { 
    variables: { id: lineId },
    onCompleted: data => {
      setAmount(data.allocationTemplateLine.amount.toDecimalPlaces(2).toFixed(2))
      setBudgetId(data.allocationTemplateLine.budget.id)
    }
  })

  const budgetQuery = useQuery<ListBudgets>(LIST_BUDGETS)
  const budgetName = budgetQuery.data?.budgets.find(b => b.id === budgetId)?.name ?? ''

  const [updateBudget] = useMutation(UPDATE_TEMPLATE_LINE, {
    variables: {
      id: lineId,
      amount: amount,
      budgetId: budgetId
    }
  })

  const navigateToTemplate = () => navigation.navigate('Template', { templateId: data?.allocationTemplateLine.allocationTemplate.id })
  const saveAndGoBack = () => {
    updateBudget()
    navigateToTemplate()
  }

  const fields: FormField[] = [
    {
      key: 'Amount',
      placeholder: 'Amount',
      value: amount,
      setValue: setAmount,
      type: FormFieldType.DecimalInput
    },
    {
      key: 'Expense/Goal',
      placeholder: 'Expense/Goal',
      value: budgetName,
      setValue: setBudgetId,
      type: FormFieldType.BudgetSelect
    }
  ]

  return <FormScreen saveAndGoBack={saveAndGoBack} fields={fields} />
}