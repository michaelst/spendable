import React, { useLayoutEffect } from 'react'
import { ActivityIndicator, RefreshControl, Text } from 'react-native'
import { useQuery } from '@apollo/client'
import TransactionRow from './TransactionRow'
import { useTheme, useNavigation } from '@react-navigation/native'
import { FlatList, TouchableWithoutFeedback } from 'react-native-gesture-handler'
import AppStyles from 'constants/AppStyles'
import { LIST_TRANSACTIONS } from '../queries'
import { ListTransactions } from '../graphql/ListTransactions'

export default function TransactionsScreen() {
  const navigation = useNavigation()
  const { colors }: any = useTheme()
  const { styles } = AppStyles()

  const { data, loading, refetch, error} = useQuery<ListTransactions>(LIST_TRANSACTIONS)
  console.log(error)

  const headerRight = () => {
    return (
      <TouchableWithoutFeedback onPress={() => navigation.navigate('Create Transaction')}>
        <Text style={styles.headerButtonText}>Add</Text>
      </TouchableWithoutFeedback>
    )
  }

  useLayoutEffect(() => navigation.setOptions({ headerRight: headerRight }))

  if (loading && !data) return <ActivityIndicator color={colors.text} style={styles.activityIndicator} />

  return (
    <FlatList
      contentContainerStyle={styles.flatlistContentContainerStyle}
      data={[...data?.transactions ?? []].sort((a, b) => b.date - a.date)}
      renderItem={({ item }) => <TransactionRow transaction={item} />}
      refreshControl={<RefreshControl refreshing={loading} onRefresh={refetch} />}
    />
  )
}