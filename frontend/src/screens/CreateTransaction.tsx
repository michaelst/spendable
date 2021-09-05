import React, { useLayoutEffect, useState } from 'react'
import { useNavigation } from '@react-navigation/native'
import { Text, View, } from 'react-native'
import { Switch } from 'react-native-gesture-handler'
import { useMutation } from '@apollo/client'
import { CREATE_TRANSACTION, LIST_TRANSACTIONS } from '../queries'
import DateInput from 'src/components/DateInput'
import FormInput from 'src/components/FormInput'
import { ListTransactions } from '../graphql/ListTransactions'
import useAppStyles from 'src/utils/useAppStyles'
import HeaderButton from 'src/components/HeaderButton'

const CreateTransaction = () => {
  const { styles } = useAppStyles()
  const navigation = useNavigation<NavigationProp>()

  const [name, setName] = useState('')
  const [amount, setAmount] = useState('')
  const [date, setDate] = useState(new Date())
  const [note, setNote] = useState('')
  const [reviewed, setReviewed] = useState(true)

  useLayoutEffect(() => navigation.setOptions({ 
    headerTitle: '', 
    headerRight: <HeaderButton onPress={saveAndGoBack} title="Save" /> 
  }))

  const [createTransaction] = useMutation(CREATE_TRANSACTION, {
    variables: {
      amount: amount,
      date: date,
      name: name,
      note: note,
      reviewed: reviewed
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

      <View style={styles.inputRow}>
        <View>
          <Text style={styles.text}>
            Reviewed
          </Text>
        </View>

        <Switch
          onValueChange={() => setReviewed(!reviewed)}
          value={reviewed}
        />
      </View>
    </View>
  )
}

export default CreateTransaction