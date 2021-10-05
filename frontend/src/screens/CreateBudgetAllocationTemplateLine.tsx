import React, { useState } from 'react'
import { View, } from 'react-native'
import { RouteProp, useRoute } from '@react-navigation/native'
import { useQuery, useMutation } from '@apollo/client'
import FormInput from 'src/components/FormInput'
import BudgetSelect from 'src/components/BudgetSelect'
import { CREATE_BUDGET_ALLOCATION_TEMPLATE_LINE, GET_BUDGET_ALLOCATION_TEMPLATE, MAIN_QUERY } from 'src/queries'
import { Main } from 'src/graphql/Main'
import { GetBudgetAllocationTemplate } from 'src/graphql/GetBudgetAllocationTemplate'
import useSaveAndGoBack from 'src/utils/useSaveAndGoBack'
import { CreateBudgetAllocationTemplateLine as CreateBudgetAllocationTemplateLineData } from 'src/graphql/CreateBudgetAllocationTemplateLine'

const CreateBudgetAllocationTemplateLine = () => {
  const { params: { templateId } } = useRoute<RouteProp<RootStackParamList, 'Create Template Line'>>()

  const [amount, setAmount] = useState('')
  const [budgetId, setBudgetId] = useState('')

  const { data } = useQuery<Main>(MAIN_QUERY)
  const budgetName = data?.budgets.find(b => b.id === budgetId)?.name ?? ''

  const [createTemplateLine] = useMutation(CREATE_BUDGET_ALLOCATION_TEMPLATE_LINE, {
    variables: {
      input: {
        amount: amount,
        budgetAllocationTemplate: { id: parseInt(templateId) },
        budget: { id: parseInt(budgetId) }
      }
    },
    update(cache, { data }) {
      const { createBudgetAllocationTemplateLine }: CreateBudgetAllocationTemplateLineData = data

      if (createBudgetAllocationTemplateLine?.result) {
        const cacheData = cache.readQuery<GetBudgetAllocationTemplate | null>({ query: GET_BUDGET_ALLOCATION_TEMPLATE, variables: { id: templateId } })
        const newCacheData = {
          ...cacheData,
          budgetAllocationTemplate: {
            ...cacheData?.budgetAllocationTemplate,
            budgetAllocationTemplateLines: [...cacheData?.budgetAllocationTemplate.budgetAllocationTemplateLines ?? []].concat([createBudgetAllocationTemplateLine.result])
          }
        }

        cache.writeQuery({
          query: GET_BUDGET_ALLOCATION_TEMPLATE,
          data: newCacheData
        })
      }
    }
  })

  useSaveAndGoBack({ mutation: createTemplateLine, action: "add expense to template" })

  return (
    <View>
      <FormInput title='Amount' value={amount} setValue={setAmount} keyboardType='decimal-pad' />
      <BudgetSelect title='Expense/Goal' value={budgetName} setValue={setBudgetId} />
    </View>
  )
}

export default CreateBudgetAllocationTemplateLine