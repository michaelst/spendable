import React, { useLayoutEffect, useState } from 'react'
import { Text, View, } from 'react-native'
import { TouchableWithoutFeedback } from 'react-native-gesture-handler'
import { RouteProp, useRoute, useNavigation } from '@react-navigation/native'
import { useQuery, useMutation } from '@apollo/client'

import { RootStackParamList } from 'components/settings/Settings'
import { GET_TEMPLATE, UPDATE_TEMPLATE } from 'components/settings/queries'
import { GetAllocationTemplate } from 'components/settings/graphql/GetAllocationTemplate'
import AppStyles from 'constants/AppStyles'
import FormInput from 'components/shared/screen/form/FormInput'

export default function TemplateEditScreen() {
  const { styles } = AppStyles()

  const navigation = useNavigation()
  const route = useRoute<RouteProp<RootStackParamList, 'Edit Template'>>()
  const { templateId } = route.params

  const { data } = useQuery<GetAllocationTemplate>(GET_TEMPLATE, { variables: { id: templateId } })

  const [name, setName] = useState(data?.allocationTemplate.name || '')

  const [updateTemplate] = useMutation(UPDATE_TEMPLATE, {
    variables: {
      id: templateId,
      name: name
    }
  })

  const navigateToTemplate = () => navigation.navigate('Template', { templateId: templateId })
  const saveAndGoBack = () => {
    updateTemplate()
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
      <FormInput title='Name' value={name} setValue={setName} />
    </View>
  )
}