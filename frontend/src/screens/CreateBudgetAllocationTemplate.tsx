import React, { useState } from 'react'
import { View, } from 'react-native'
import { useMutation } from '@apollo/client'
import FormInput from 'src/components/FormInput'
import { CREATE_BUDGET_ALLOCATION_TEMPLATE, LIST_BUDGET_ALLOCATION_TEMPLATES } from 'src/queries'
import { ListBudgetAllocationTemplates } from 'src/graphql/ListBudgetAllocationTemplates'
import useSaveAndGoBack from 'src/utils/useSaveAndGoBack'
import { CreateBudgetAllocationTemplate as CreateBudgetAllocationTemplateData } from 'src/graphql/CreateBudgetAllocationTemplate'

const CreateBudgetAllocationTemplate = () => {
  const [name, setName] = useState('')

  const [createTemplate] = useMutation(CREATE_BUDGET_ALLOCATION_TEMPLATE, {
    variables: {
      input: {
        name: name
      }
    },
    update(cache, { data }) {
      const { createBudgetAllocationTemplate }: CreateBudgetAllocationTemplateData = data

      if (createBudgetAllocationTemplate) {
        const cacheData = cache.readQuery<ListBudgetAllocationTemplates | null>({ query: LIST_BUDGET_ALLOCATION_TEMPLATES })
        const newCacheData = {
          ...cacheData,
          allocationTemplates: [...data?.budgetAllocationTemplates || []].concat([createBudgetAllocationTemplate.result])
        }

        cache.writeQuery({
          query: LIST_BUDGET_ALLOCATION_TEMPLATES,
          data: newCacheData
        })
      }
    }
  })

  useSaveAndGoBack({ mutation: createTemplate, action: "create template" })

  return (
    <View>
      <FormInput title='Name' value={name} setValue={setName} />
    </View>
  )
}

export default CreateBudgetAllocationTemplate