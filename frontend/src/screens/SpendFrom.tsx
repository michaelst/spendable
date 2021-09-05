import React, { useLayoutEffect } from 'react'
import { ActivityIndicator } from 'react-native'
import { RouteProp, useRoute, useNavigation } from '@react-navigation/native'
import { useQuery } from '@apollo/client'
import { GET_TRANSACTION } from '../queries'
import { GetTransaction } from '../graphql/GetTransaction'
import useAppStyles from 'src/utils/useAppStyles'
import { FlatList } from 'react-native-gesture-handler'
import TransactionAllocationRow from '../components/TransactionAllocationRow'
import getAllocations from '../utils/getAllocations'
import HeaderButton from 'src/components/HeaderButton'

const SpendFrom = () => {
  const { styles, colors } = useAppStyles()
  const navigation = useNavigation<NavigationProp>()
  const { params: { transactionId } } = useRoute<RouteProp<RootStackParamList, 'Spend From'>>()

  const navigateToCreate = () => navigation.navigate('Create Allocation', { transactionId: transactionId })

  useLayoutEffect(() => navigation.setOptions({
    headerTitle: '',
    headerRight: <HeaderButton onPress={navigateToCreate} title="Add" />
  }))

  const { data } = useQuery<GetTransaction>(GET_TRANSACTION, { variables: { id: transactionId } })

  if (!data) return <ActivityIndicator color={colors.text} style={styles.activityIndicator} />

  const allocations = getAllocations(data.transaction)

  return (
    <FlatList
      contentContainerStyle={styles.flatlistContentContainerStyle}
      data={allocations}
      renderItem={({ item }) => <TransactionAllocationRow allocation={item} transactionId={transactionId} />}
    />
  )
}

export default SpendFrom