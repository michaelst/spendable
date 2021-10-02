import React, { useState } from 'react'
import { Text, View, } from 'react-native'
import { Switch } from 'react-native-gesture-handler'
import { useMutation } from '@apollo/client'
import { CREATE_TRANSACTION, LIST_TRANSACTIONS } from '../queries'
import DateInput from 'src/components/DateInput'
import FormInput from 'src/components/FormInput'
import { ListTransactions } from '../graphql/ListTransactions'
import useAppStyles from 'src/utils/useAppStyles'
import { DateTime } from 'luxon'
import { CreateTransaction as CreateTransactionData } from 'src/graphql/CreateTransaction'
import useSaveAndGoBack from 'src/utils/useSaveAndGoBack'

const CreateTransaction = () => {
  const { styles } = useAppStyles()

  const [name, setName] = useState('')
  const [amount, setAmount] = useState('')
  const [date, setDate] = useState(new Date())
  const [note, setNote] = useState('')
  const [reviewed, setReviewed] = useState(true)

  const [createTransaction] = useMutation(CREATE_TRANSACTION, {
    variables: {
      input: {
        amount: amount,
        date: DateTime.fromJSDate(date).toISODate(),
        name: name,
        note: note,
        reviewed: reviewed
      }
    },
    update(cache, { data }) {
      const { createTransaction }: CreateTransactionData = data

      if (createTransaction?.result) {
        const cacheData = cache.readQuery<ListTransactions | null>({ query: LIST_TRANSACTIONS })
        const newCacheData = {
          ...cacheData,
          transactions: {
            ...cacheData?.transactions,
            results: [...cacheData?.transactions?.results ?? []].concat([createTransaction.result])
          }
        }

        cache.writeQuery({
          query: LIST_TRANSACTIONS,
          data: newCacheData
        })
      }
    }
  })

  useSaveAndGoBack({ mutation: createTransaction, action: "create tranasction" })

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