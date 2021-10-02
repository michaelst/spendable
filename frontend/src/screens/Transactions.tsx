import React, { useLayoutEffect } from 'react'
import { ActivityIndicator, RefreshControl } from 'react-native'
import { useQuery } from '@apollo/client'
import TransactionRow, { TransactionRowItem } from '../components/TransactionRow'
import { useNavigation } from '@react-navigation/native'
import { FlatList } from 'react-native-gesture-handler'
import { LIST_TRANSACTIONS } from '../queries'
import { ListTransactions } from '../graphql/ListTransactions'
import useAppStyles from 'src/utils/useAppStyles'
import HeaderButton from 'src/components/HeaderButton'

const Transactions = () => {
  const navigation = useNavigation<NavigationProp>()
  const { styles, colors } = useAppStyles()

  const { data, loading, refetch } = useQuery<ListTransactions>(LIST_TRANSACTIONS)

  useLayoutEffect(() => navigation.setOptions({ 
    headerRight: () => <HeaderButton onPress={() => navigation.navigate('Create Transaction')} title="Add" /> 
  }))

  if (loading && !data) return <ActivityIndicator color={colors.text} style={styles.activityIndicator} />

  const transactions: TransactionRowItem[] =
  [...data?.transactions?.results ?? []]
    .sort((a, b) => b.date - a.date)
    .map(transaction => ({
      key: transaction.id,
      transactionId: transaction.id,
      title: transaction.name,
      amount: transaction.amount,
      transactionDate: transaction.date,
      transactionReviewed: transaction.reviewed,
      onPress: () => navigation.navigate('Transaction', { transactionId: transaction.id })
    }))

  return (
    <FlatList
      data={transactions}
      renderItem={({ item }) => <TransactionRow item={item} />}
      refreshControl={<RefreshControl refreshing={loading} onRefresh={refetch} />}
      contentInsetAdjustmentBehavior="automatic"
    />
  )
}

export default Transactions