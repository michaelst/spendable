import React, { useLayoutEffect, useState } from 'react'
import { useNavigation } from '@react-navigation/native'
import { ActivityIndicator, Alert, Text, View, } from 'react-native'
import { Switch } from 'react-native-gesture-handler'
import { useMutation } from '@apollo/client'
import { CREATE_TRANSACTION, LIST_TRANSACTIONS } from '../queries'
import DateInput from 'src/components/DateInput'
import FormInput from 'src/components/FormInput'
import { ListTransactions } from '../graphql/ListTransactions'
import useAppStyles from 'src/utils/useAppStyles'
import HeaderButton from 'src/components/HeaderButton'
import { DateTime } from 'luxon'
import { CreateTransaction as CreateTransactionData } from 'src/graphql/CreateTransaction'

const CreateTransaction = () => {
  const { styles, colors } = useAppStyles()
  const navigation = useNavigation<NavigationProp>()

  const [loading, setLoading] = useState(false)
  const [name, setName] = useState('')
  const [amount, setAmount] = useState('')
  const [date, setDate] = useState(new Date())
  const [note, setNote] = useState('')
  const [reviewed, setReviewed] = useState(true)

  useLayoutEffect(() => navigation.setOptions({
    headerTitle: '',
    headerRight: () => (
      <View>
        {loading ?
          <ActivityIndicator color={colors.text} style={styles.activityIndicator} /> :
          <HeaderButton onPress={saveAndGoBack} title="Save" />}
      </View>
    )
  }))

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

  const saveAndGoBack = () => {
    setLoading(true)
    createTransaction().then(() => {
      setLoading(false)
      navigation.goBack()
    }).catch(() => {
      Alert.alert("Failed to create transaction, please try again.")
      setLoading(false)
    })
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