import React, { useLayoutEffect, useState } from 'react'
import { Ionicons } from '@expo/vector-icons'
import { RouteProp, useRoute, useNavigation, useTheme } from '@react-navigation/native'
import { ActivityIndicator, Text, View, } from 'react-native'
import { TouchableHighlight, TouchableWithoutFeedback } from 'react-native-gesture-handler'
import { useMutation, useQuery } from '@apollo/client'

import { GET_TRANSACTION, UPDATE_TRANSACTION } from '../queries'
import { GetTransaction } from '../graphql/GetTransaction'
import { LIST_BUDGETS } from 'components/budgets/queries'
import { RootStackParamList } from '../Transactions'
import AppStyles from 'constants/AppStyles'
import BudgetSelect from 'components/shared/screen/form/BudgetSelect'
import DateInput from 'components/shared/screen/form/DateInput'
import FormInput from 'components/shared/screen/form/FormInput'
import getAllocations from '../helpers/getAllocations'
import { GET_SPENDABLE } from 'components/headers/spendable-header/queries'
import TemplateSelect from './TemplateSelect'

export default function TransactionScreen() {
  const { colors }: any = useTheme()
  const { styles, padding, fontSize } = AppStyles()
  const navigation = useNavigation()
  const route = useRoute<RouteProp<RootStackParamList, 'Transaction'>>()
  const { transactionId } = route.params

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

  const { data } = useQuery<GetTransaction>(GET_TRANSACTION, {
    variables: { id: transactionId },
    onCompleted: data => {
      setName(data.transaction.name ?? '')
      setAmount(data.transaction.amount.toDecimalPlaces(2).toFixed(2))
      setDate(data.transaction.date)
      setNote(data.transaction.note ?? '')
    }
  })

  const [updateTransaction] = useMutation(UPDATE_TRANSACTION, {
    refetchQueries: [{ query: LIST_BUDGETS }, { query: GET_SPENDABLE }]
  })

  if (!data?.transaction) {
    return <ActivityIndicator color={colors.text} style={styles.activityIndicator} />
  }

  const allocations = getAllocations(data.transaction)

  const spendFromValue = allocations.length > 0
    ? allocations.map(a => a.budget.name).join(', ')
    : 'Spendable'

  const setSpendFrom = (budgetId: string) => {
    if (budgetId === 'spendable') {
      updateTransaction({ variables: { id: transactionId, allocations: [] } })
    } else {
      updateTransaction({
        variables: {
          id: transactionId, allocations: [{
            amount: amount,
            budgetId: budgetId
          }]
        }
      })
    }
  }

  const navigateToSpendFrom = () => navigation.navigate('Spend From', { transactionId: transactionId })
  const navigateToTransactions = () => navigation.navigate('Transactions')
  const saveAndGoBack = () => {
    updateTransaction({
      variables: {
        id: transactionId,
        amount: amount,
        date: date,
        name: name,
        note: note
      }
    })
    navigateToTransactions()
  }

  return (
    <View style={{ flex: 1 }}>
      <FormInput title='Name' value={name} setValue={setName} />
      <FormInput title='Amount' value={amount} setValue={setAmount} keyboardType='decimal-pad' />
      <DateInput title='Date' value={date} setValue={setDate} />
      <FormInput title='Note' value={note} setValue={setNote} multiline={true} />

      {data.transaction.bankTransaction ? (
        <Text style={{ ...styles.secondaryText, ...{ padding: padding * 2, paddingTop: padding } }}>
          Bank Memo: {data?.transaction.bankTransaction?.name}
        </Text>
      ) : null}

      <View style={{ paddingTop: padding * 3 }}>
        {allocations.length <= 1
          ? <BudgetSelect title='Spend From' value={spendFromValue} setValue={setSpendFrom} />
          : (
            <TouchableHighlight onPress={navigateToSpendFrom}>
              <View style={styles.row}>
                <View style={{ flex: 1 }}>
                  <Text style={styles.text}>
                    Spend From
                </Text>
                </View>

                <View style={{ flex: 1, flexDirection: "row", alignItems: 'center', paddingRight: padding }}>
                  <Text style={[styles.formInputText, { paddingRight: padding }]}>
                    {spendFromValue}
                  </Text>
                  <Ionicons name='ios-arrow-forward' size={fontSize} color={colors.secondary} />
                </View>
              </View>
            </TouchableHighlight>
          )}
      </View>

      <View style={{ flexDirection: "row" }}>
        <View style={{ flexDirection: "row", width: '50%' }}>
          <TouchableHighlight onPress={navigateToSpendFrom}>
            <Text style={styles.smallButtonText}>Split</Text>
          </TouchableHighlight>
        </View>
        <View style={{ flexDirection: "row", justifyContent: 'flex-end', width: '50%' }}>
          <TemplateSelect setValue={allocations => updateTransaction({ variables: { id: transactionId, allocations: allocations } })} />
        </View>
      </View>
    </View>
  )
}