import React, { useState } from 'react'
import { View, } from 'react-native'
import { RouteProp, useRoute } from '@react-navigation/native'
import { useQuery, useMutation } from '@apollo/client'
import FormInput from 'src/components/FormInput'
import { GET_BUDGET_ALLOCATION_TEMPLATE, UPDATE_BUDGET_ALLOCATION_TEMPLATE } from 'src/queries'
import { GetBudgetAllocationTemplate } from 'src/graphql/GetBudgetAllocationTemplate'
import useSaveAndGoBack from 'src/utils/useSaveAndGoBack'

const EditBudgetAllocationTemplate = () => {
  const route = useRoute<RouteProp<RootStackParamList, 'Edit Template'>>()
  const { templateId } = route.params

  const { data } = useQuery<GetBudgetAllocationTemplate>(GET_BUDGET_ALLOCATION_TEMPLATE, { variables: { id: templateId } })

  const [name, setName] = useState(data?.budgetAllocationTemplate.name || '')

  const [updateTemplate] = useMutation(UPDATE_BUDGET_ALLOCATION_TEMPLATE, {
    variables: {
      id: templateId,
      input: {
        name: name
      }
    }
  })

  useSaveAndGoBack({ mutation: updateTemplate, action: "update template" })

  return (
    <View>
      <FormInput title='Name' value={name} setValue={setName} />
    </View>
  )
}

export default EditBudgetAllocationTemplate