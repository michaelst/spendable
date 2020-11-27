import React, { useLayoutEffect, useState } from 'react'
import { useNavigation } from '@react-navigation/native'
import { Text, View, } from 'react-native'
import { TouchableWithoutFeedback } from 'react-native-gesture-handler'
import { useMutation } from '@apollo/client'

import { CREATE_TRANSACTION, LIST_TRANSACTIONS } from '../queries'
import { LIST_BUDGETS } from 'components/budgets/queries'
import AppStyles from 'constants/AppStyles'
import DateInput from 'components/shared/screen/form/DateInput'
import FormInput from 'components/shared/screen/form/FormInput'
import { GET_SPENDABLE } from 'components/headers/spendable-header/queries'
import { ListTransactions } from '../graphql/ListTransactions'

export default function TransactionCreateScreen() {
  const { styles } = AppStyles()
  const navigation = useNavigation()

  const [name, setName] = useState('')
  const [amount, setAmount] = useState('')
  const [date, setDate] = useState(new Date())
  const [note, setNote] = useState('')

  const headerRight = () => {
    return (
      <TouchableWithoutFeedback onPress={saveAndGoBack}>
        <Text style={styles.headerButtonText}>Save</Text>
      </TouchableWithoutFeedback>
    )
  }

  useLayoutEffect(() => navigation.setOptions({ headerTitle: '', headerRight: headerRight }))

  const [createTransaction] = useMutation(CREATE_TRANSACTION, {
    variables: {
      amount: amount,
      date: date,
      name: name,
      note: note
    },
    update(cache, { data: { createTransaction } }) {
      const data = cache.readQuery<ListTransactions | null>({ query: LIST_TRANSACTIONS })

      cache.writeQuery({
        query: LIST_TRANSACTIONS,
        data: { transactions: (data?.transactions ?? []).concat([createTransaction]) }
      })
    }
  })

  const navigateToTransactions = () => navigation.navigate('Transactions')
  const saveAndGoBack = () => {
    createTransaction()
    navigateToTransactions()
  }

  return (
    <View style={{ flex: 1 }}>
      <FormInput title='Name' value={name} setValue={setName} />
      <FormInput title='Amount' value={amount} setValue={setAmount} keyboardType='decimal-pad' />
      <DateInput title='Date' value={date} setValue={setDate} />
      <FormInput title='Note' value={note} setValue={setNote} multiline={true} />
    </View>
  )
}