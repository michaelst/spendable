import React, { useLayoutEffect, useState } from 'react'
import { View, } from 'react-native'
import { useMutation } from '@apollo/client'
import { useNavigation } from '@react-navigation/native'
import FormInput from 'src/components/FormInput'
import HeaderButton from 'src/components/HeaderButton'
import { CREATE_BUDGET_ALLOCATION_TEMPLATE, LIST_BUDGET_ALLOCATION_TEMPLATES } from 'src/queries'
import { ListBudgetAllocationTemplates } from 'src/graphql/ListBudgetAllocationTemplates'

const CreateBudgetAllocationTemplate = () => {
  const navigation = useNavigation<NavigationProp>()

  const [name, setName] = useState('')

  const [createTemplate] = useMutation(CREATE_BUDGET_ALLOCATION_TEMPLATE, {
    variables: {
      name: name
    },
    update(cache, { data: { createAllocationTemplate } }) {
      const data = cache.readQuery<ListBudgetAllocationTemplates | null>({ query: LIST_BUDGET_ALLOCATION_TEMPLATES })

      cache.writeQuery({
        query: LIST_BUDGET_ALLOCATION_TEMPLATES,
        data: { allocationTemplates: data?.budgetAllocationTemplates.concat([createAllocationTemplate]) }
      })
    }
  })

  const saveAndGoBack = () => {
    createTemplate()
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

export default CreateBudgetAllocationTemplate