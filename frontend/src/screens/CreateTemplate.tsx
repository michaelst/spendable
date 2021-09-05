import React, { useLayoutEffect, useState } from 'react'
import { View, } from 'react-native'
import { useMutation } from '@apollo/client'
import { useNavigation } from '@react-navigation/native'
import { CREATE_TEMPLATE, LIST_TEMPLATES } from 'src/screens/settings/queries'
import { ListAllocationTemplates } from './settings/graphql/ListAllocationTemplates'
import useAppStyles from 'src/utils/useAppStyles'
import FormInput from 'src/components/FormInput'
import HeaderButton from 'src/components/HeaderButton'

const CreateTemplate = () => {
  const navigation = useNavigation<NavigationProp>()

  const [name, setName] = useState('')

  const [createTemplate] = useMutation(CREATE_TEMPLATE, {
    variables: {
      name: name
    },
    update(cache, { data: { createAllocationTemplate } }) {
      const data = cache.readQuery<ListAllocationTemplates | null>({ query: LIST_TEMPLATES })

      cache.writeQuery({
        query: LIST_TEMPLATES,
        data: { allocationTemplates: data?.allocationTemplates.concat([createAllocationTemplate]) }
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

export default CreateTemplate