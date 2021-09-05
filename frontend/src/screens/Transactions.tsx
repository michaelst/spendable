import React, { useLayoutEffect } from 'react'
import { ActivityIndicator, RefreshControl } from 'react-native'
import { useQuery } from '@apollo/client'
import TransactionRow from '../components/TransactionRow'
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

  return (
    <FlatList
      contentContainerStyle={styles.flatlistContentContainerStyle}
      data={[...data?.transactions ?? []].sort((a, b) => b.date - a.date)}
      renderItem={({ item }) => <TransactionRow transaction={item} />}
      refreshControl={<RefreshControl refreshing={loading} onRefresh={refetch} />}
    />
  )
}

export default Transactions