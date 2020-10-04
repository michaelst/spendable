import React, { useState } from 'react'
import { useNavigation } from '@react-navigation/native'
import { useMutation } from '@apollo/client'
import { CREATE_TEMPLATE, LIST_TEMPLATES } from 'components/settings/queries'
import FormScreen, { FormFields } from 'components/shared/screen/form/FormScreen'
import { ListAllocationTemplates } from '../graphql/ListAllocationTemplates'

export default function TemplateEditScreen() {
  const navigation = useNavigation()

  const [name, setName] = useState('')

  const [createTemplate, { error }] = useMutation(CREATE_TEMPLATE, {
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

  const fields: FormFields = [
    {
      key: 'name',
      placeholder: 'Name',
      value: name,
      setValue: setName,
      keyboardType: 'default'
    }
  ]

  return <FormScreen saveAndGoBack={saveAndGoBack} fields={fields} />
}