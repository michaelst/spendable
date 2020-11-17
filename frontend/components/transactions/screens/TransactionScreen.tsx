import React, { useLayoutEffect, useState } from 'react'
import { Text, View, } from 'react-native'
import { RouteProp, useRoute, useNavigation } from '@react-navigation/native'
import { useMutation, useQuery } from '@apollo/client'
import { RootStackParamList } from '../Transactions'
import { GET_TRANSACTION, UPDATE_TRANSACTION } from '../queries'
import { GetTransaction } from '../graphql/GetTransaction'
import FormInput, { FormFieldType } from 'components/shared/screen/form/FormInput'
import AppStyles from 'constants/AppStyles'
import DateInput from 'components/shared/screen/form/DateInput'
import { TouchableWithoutFeedback } from 'react-native-gesture-handler'
import { AllocationInputObject } from 'graphql/globalTypes'
import { ListBudgets } from 'components/budgets/graphql/ListBudgets'
import { LIST_BUDGETS } from 'components/budgets/queries'
import BudgetSelect from 'components/shared/screen/form/BudgetSelect'

export default function TransactionScreen() {
  const { styles, padding } = AppStyles()
  const navigation = useNavigation()
  const route = useRoute<RouteProp<RootStackParamList, 'Transaction'>>()
  const { transactionId } = route.params

  const [name, setName] = useState('')
  const [amount, setAmount] = useState('')
  const [date, setDate] = useState(new Date())
  const [note, setNote] = useState('')
  const [allocations, setAllocations] = useState<AllocationInputObject[]>([])

  const { data: budgetsData, refetch: refetchBudgets } = useQuery<ListBudgets>(LIST_BUDGETS)
  const getTransaction = useQuery<GetTransaction>(GET_TRANSACTION, { 
    variables: { id: transactionId },
    onCompleted: data => {
      setName(data.transaction.name ?? '')
      setAmount(data.transaction.amount.toDecimalPlaces(2).toFixed(2))
      setDate(data.transaction.date)
      setNote(data.transaction.note ?? '')

      const allocations = data.transaction.allocations.map(a => ({ id: a.id, amount: a.amount, budgetId: a.budget.id }))
      setAllocations(allocations)
    }
  })

  const [updateTransactions] = useMutation(UPDATE_TRANSACTION, {
    variables: {
      id: transactionId,
      amount: amount,
      date: date,
      name: name,
      note: note,
      allocations: allocations
    }
  })

  const spendFromValue = allocations.length > 0 
    ? allocations.map(a => budgetsData?.budgets.find(b => b.id === a.budgetId)?.name).join(', ') 
    : 'Spendable'

  const setSpendFrom = (budgetId: string) => {
    if (budgetId === 'spendable') {
      setAllocations([])
    } else {
      setAllocations([{
        amount: amount,
        budgetId: budgetId
      }])
    }
  }

  const navigateToTransactions = () => navigation.navigate('Transactions')
  const saveAndGoBack = () => {
    updateTransactions().then(() => refetchBudgets())
    navigateToTransactions()
  }

  const headerRight = () => {
    return (
      <TouchableWithoutFeedback onPress={saveAndGoBack}>
        <Text style={styles.headerButtonText}>Save</Text>
      </TouchableWithoutFeedback>
    )
  }

  useLayoutEffect(() => navigation.setOptions({ headerTitle: '', headerRight: headerRight }))

  return (
    <View>
      <FormInput info={{
        key: 'name',
        placeholder: 'Name',
        value: name,
        setValue: setName,
        type: FormFieldType.StringInput
      }} />
      <FormInput info={{
        key: 'amount',
        placeholder: 'Amount',
        value: amount,
        setValue: setAmount,
        type: FormFieldType.DecimalInput
      }} />
      <DateInput info={{
        key: 'date',
        placeholder: 'Date',
        value: date,
        setValue: setDate
      }} />
      <FormInput info={{
        key: 'note',
        placeholder: 'Note',
        value: note,
        setValue: setNote,
        type: FormFieldType.MultiLineStringInput
      }} />
      <Text style={{...styles.secondaryText, ...{paddingLeft: padding * 2, paddingTop: padding, paddingBottom: padding * 3}}}>
        Bank Memo: {getTransaction.data?.transaction.bankTransaction?.name}
      </Text>
      <BudgetSelect info={{
        key: 'spend-from',
        placeholder: 'Spend From',
        value: spendFromValue,
        setValue: setSpendFrom,
        type: FormFieldType.StringInput
      }} />
    </View>
  )
}