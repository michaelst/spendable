import React, { useLayoutEffect, useState } from 'react'
import { View, } from 'react-native'
import { RouteProp, useRoute, useNavigation } from '@react-navigation/native'
import { useQuery, useMutation } from '@apollo/client'
import FormInput from 'src/components/FormInput'
import HeaderButton from 'src/components/HeaderButton'
import { GET_BUDGET_ALLOCATION_TEMPLATE, UPDATE_BUDGET_ALLOCATION_TEMPLATE } from 'src/queries'
import { GetBudgetAllocationTemplate } from 'src/graphql/GetBudgetAllocationTemplate'

const EditBudgetAllocationTemplate = () => {

  const navigation = useNavigation()
  const route = useRoute<RouteProp<RootStackParamList, 'Edit Template'>>()
  const { templateId } = route.params

  const { data } = useQuery<GetBudgetAllocationTemplate>(GET_BUDGET_ALLOCATION_TEMPLATE, { variables: { id: templateId } })

  const [name, setName] = useState(data?.budgetAllocationTemplate.name || '')

  const [updateTemplate] = useMutation(UPDATE_BUDGET_ALLOCATION_TEMPLATE, {
    variables: {
      id: templateId,
      name: name
    }
  })

  const saveAndGoBack = () => {
    updateTemplate()
    navigation.goBack()
  }

  useLayoutEffect(() => navigation.setOptions({ 
    headerTitle: '', 
    headerRight: () => <HeaderButton onPress={saveAndGoBack} title="Save" /> 
  }))

  return (
    <View>
      <FormInput title='Name' value={name} setValue={setName} />
    </View>
  )
}

export default EditBudgetAllocationTemplate