import React, { useState } from 'react'
import { Text, View, } from 'react-native'
import { RouteProp, useRoute, useNavigation } from '@react-navigation/native'
import { useMutation, useQuery } from '@apollo/client'
import { RootStackParamList } from '../Transactions'
import { GET_TRANSACTION, UPDATE_TRANSACTION } from '../queries'
import { GetTransaction } from '../graphql/GetTransaction'
import { FormField, FormFieldType } from 'components/shared/screen/form/FormInput'
import FormScreen from 'components/shared/screen/form/FormScreen'
import AppStyles from 'constants/AppStyles'
import { DateField } from 'components/shared/screen/form/DateInput'

export default function TransactionScreen() {
  const { styles, padding } = AppStyles()
  const navigation = useNavigation()
  const route = useRoute<RouteProp<RootStackParamList, 'Transaction'>>()
  const { transactionId } = route.params

  const [name, setName] = useState('')
  const [amount, setAmount] = useState('')
  const [date, setDate] = useState(new Date())

  const { data } = useQuery<GetTransaction>(GET_TRANSACTION, { 
    variables: { id: transactionId },
    onCompleted: data => {
      setName(data.transaction.name ?? '')
      setAmount(data.transaction.amount.toDecimalPlaces(2).toFixed(2))
      setDate(data.transaction.date)
    }
  })


  const [updateTransactions] = useMutation(UPDATE_TRANSACTION, {
    variables: {
      id: transactionId,
      name: name
    }
  })

  const navigateToTransactions = () => navigation.navigate('Transactions')
  const saveAndGoBack = () => {
    updateTransactions()
    navigateToTransactions()
  }

  const fields: (FormField | DateField)[] = [
    {
      key: 'name',
      placeholder: 'Name',
      value: name,
      setValue: setName,
      type: FormFieldType.StringInput
    },
    {
      key: 'amount',
      placeholder: 'Amount',
      value: amount,
      setValue: setAmount,
      type: FormFieldType.DecimalInput
    },
    {
      key: 'date',
      placeholder: 'Date',
      value: date,
      setValue: setDate,
      type: FormFieldType.DatePicker
    }
  ]

  return (
    <View>
      <FormScreen saveAndGoBack={saveAndGoBack} fields={fields} />
      <Text style={{...styles.secondaryText, ...{padding: padding, paddingTop: 8}}}>
        Bank Memo: {data?.transaction.bankTransaction?.name}
      </Text>
    </View>
  )
}