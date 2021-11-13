import React, { useState } from 'react'
import { View } from 'react-native'
import { useMutation } from '@apollo/client'
import { CREATE_BUDGET, MAIN_QUERY } from 'src/queries'
import useSaveAndGoBack from 'src/hooks/useSaveAndGoBack'
import FormInput from 'src/components/FormInput'

const CreateBudget = () => {
  const [name, setName] = useState('')
  const [balance, setBalance] = useState('0.00')

  const [createBudget] = useMutation(CREATE_BUDGET, {
    variables: {
      input: {
        name: name,
        adjustment: balance
      }
    },
    refetchQueries: [{ query: MAIN_QUERY }]
  })

  useSaveAndGoBack({ mutation: createBudget, action: "create expense" })

  return (
    <View style={{ flex: 1 }}>
      <FormInput title='Name' value={name} setValue={setName} />
      <FormInput title='Balance' value={balance} setValue={setBalance} keyboardType='decimal-pad' />
    </View>
  )
}

export default CreateBudget