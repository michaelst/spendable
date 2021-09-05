import React, { useLayoutEffect, useState } from 'react'
import { View, } from 'react-native'
import { RouteProp, useRoute, useNavigation } from '@react-navigation/native'
import { useQuery, useMutation } from '@apollo/client'
import useAppStyles from 'src/utils/useAppStyles'
import FormInput from 'src/components/FormInput'
import HeaderButton from 'src/components/HeaderButton'
import { GetAllocationTemplate } from 'src/graphql/GetAllocationTemplate'
import { GET_TEMPLATE, UPDATE_TEMPLATE } from 'src/queries'

const EditTemplate = () => {
  const { styles } = useAppStyles()

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

export default EditTemplate