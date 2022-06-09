import React, { useLayoutEffect, useState } from 'react'
import { RouteProp, useRoute, useNavigation } from '@react-navigation/native'
import { ActivityIndicator, Text, View, } from 'react-native'
import { Switch, TouchableHighlight } from 'react-native-gesture-handler'
import { useMutation, useQuery } from '@apollo/client'
import { GET_TRANSACTION, MAIN_QUERY, UPDATE_TRANSACTION } from '../queries'
import { GetTransaction } from '../graphql/GetTransaction'
import useAppStyles from 'src/hooks/useAppStyles'
import BudgetSelect from 'src/components/BudgetSelect'
import DateInput from 'src/components/DateInput'
import FormInput from 'src/components/FormInput'
import TemplateSelect from '../components/TemplateSelect'
import HeaderButton from 'src/components/HeaderButton'
import { faChevronRight } from '@fortawesome/free-solid-svg-icons'
import { FontAwesomeIcon } from '@fortawesome/react-native-fontawesome'
import { DateTime } from 'luxon'

const Transaction = () => {
  const { styles, colors, fontSize, baseUnit } = useAppStyles()
  const navigation = useNavigation<NavigationProp>()
  const route = useRoute<RouteProp<RootStackParamList, 'Transaction'>>()
  const { transactionId } = route.params

  const [name, setName] = useState('')
  const [amount, setAmount] = useState('')
  const [date, setDate] = useState(new Date())
  const [note, setNote] = useState('')
  const [reviewed, setReviewed] = useState(false)

  useLayoutEffect(() => navigation.setOptions({
    headerTitle: '',
    headerRight: () => <HeaderButton onPress={saveAndGoBack} title="Save" />
  }))

  const { data } = useQuery<GetTransaction>(GET_TRANSACTION, {
    variables: { id: transactionId },
    onCompleted: data => {
      setName(data.transaction.name ?? '')
      setAmount(data.transaction.amount.toDecimalPlaces(2).toFixed(2))
      setDate(data.transaction.date)
      setNote(data.transaction.note ?? '')
      setReviewed(data.transaction.reviewed)
    }
  })

  const [updateTransaction] = useMutation(UPDATE_TRANSACTION, {
    refetchQueries: [{ query: MAIN_QUERY }]
  })

  if (!data?.transaction) return <ActivityIndicator color={colors.text} style={styles.activityIndicator} />

  const allocations = data.transaction.budgetAllocations

  const spendFromValue = allocations.map(a => a.budget.name).join(', ')

  const setSpendFrom = (budgetId: string) => {
    updateTransaction({
      variables: {
        id: transactionId,
        input: {
          budgetAllocations: [{
            amount: amount,
            budget: { id: parseInt(budgetId) }
          }]
        }
      }
    })
  }

  const navigateToSpendFrom = () => navigation.navigate('Spend From', { transactionId: transactionId })
  const saveAndGoBack = () => {
    updateTransaction({
      variables: {
        id: transactionId,
        input: {
          amount: amount,
          date: DateTime.fromJSDate(date).toISODate(),
          name: name,
          note: note,
          reviewed: reviewed
        }
      }
    })
    navigation.goBack()
  }

  return (
    <View style={{ flex: 1 }}>
      <FormInput title='Name' value={name} setValue={setName} />
      <FormInput title='Amount' value={amount} setValue={setAmount} keyboardType='decimal-pad' />
      <DateInput title='Date' value={date} setValue={setDate} />
      <FormInput title='Note' value={note} setValue={setNote} multiline={true} />

      <View style={[styles.inputRow, { padding: baseUnit }]}>
        <View style={{ flex: 1 }}>
          <Text style={[styles.text, { padding: baseUnit }]}>
            Reviewed
          </Text>
        </View>

        <View style={{ flexDirection: "row", paddingRight: baseUnit }}>
          <Switch
            onValueChange={() => setReviewed(!reviewed)}
            value={reviewed}
          />
        </View>
      </View>

      {data.transaction.bankTransaction ? (
        <Text style={{ ...styles.secondaryText, ...{ padding: baseUnit * 2, paddingTop: baseUnit } }}>
          Bank Memo: {data?.transaction.bankTransaction?.name}
        </Text>
      ) : null}

      <View style={{ paddingTop: baseUnit * 3 }}>
        {allocations.length <= 1
          ? <BudgetSelect title='Spend From' value={spendFromValue} setValue={setSpendFrom} />
          : (
            <TouchableHighlight onPress={navigateToSpendFrom}>
              <View style={[styles.inputRow]}>
                <View style={styles.flex}>
                  <Text numberOfLines={1} style={styles.text}>
                    Spend From
                  </Text>
                </View>

                <View style={{ flexDirection: "row", alignItems: 'center', maxWidth: '60%' }}>
                  <Text style={[styles.formInputText, { paddingRight: baseUnit }]}>
                    {spendFromValue}
                  </Text>
                  <FontAwesomeIcon icon={faChevronRight} size={fontSize} color={colors.secondary} />
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
          <TemplateSelect setValue={allocations => updateTransaction({ variables: { id: transactionId, input: { budgetAllocations: allocations } } })} />
        </View>
      </View>
    </View>
  )
}

export default Transaction