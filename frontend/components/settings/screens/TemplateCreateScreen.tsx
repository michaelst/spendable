import React, { useLayoutEffect, useState } from 'react'
import { Text, View, } from 'react-native'
import { TouchableWithoutFeedback } from 'react-native-gesture-handler'
import { useMutation } from '@apollo/client'
import { useNavigation } from '@react-navigation/native'

import { CREATE_TEMPLATE, LIST_TEMPLATES } from 'components/settings/queries'
import { ListAllocationTemplates } from '../graphql/ListAllocationTemplates'
import AppStyles from 'constants/AppStyles'
import FormInput from 'components/shared/screen/form/FormInput'

export default function TemplateEditScreen() {
  const { styles } = AppStyles()
  
  const navigation = useNavigation()

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

  const navigateToTemplates = () => navigation.navigate('Templates')
  const saveAndGoBack = () => {
    createTemplate()
    navigateToTemplates()
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
      <FormInput title='Name' value={name} setValue={setName} />
    </View>
  )
}