import React, { useState } from 'react'
import { RouteProp, useRoute, useNavigation } from '@react-navigation/native'
import { useQuery, useMutation } from '@apollo/client'
import { RootStackParamList } from 'components/settings/Settings'
import { GET_TEMPLATE, UPDATE_TEMPLATE } from 'components/settings/queries'
import { GetAllocationTemplate } from 'components/settings/graphql/GetAllocationTemplate'
import FormScreen, { FormField, FormFieldType } from 'components/shared/screen/form/FormScreen'

export default function TemplateEditScreen() {
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

  const fields: FormField[] = [
    {
      key: 'name',
      placeholder: 'Name',
      value: name,
      setValue: setName,
      type: FormFieldType.StringInput
    }
  ]

  return <FormScreen saveAndGoBack={saveAndGoBack} fields={fields} />
}