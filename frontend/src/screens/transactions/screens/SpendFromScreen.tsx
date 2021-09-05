import React, { useLayoutEffect } from 'react'
import { ActivityIndicator, Text } from 'react-native'
import { RouteProp, useRoute, useNavigation, useTheme } from '@react-navigation/native'
import { useQuery } from '@apollo/client'
import { RootStackParamList } from '../Transactions'
import { GET_TRANSACTION } from '../queries'
import { GetTransaction } from '../graphql/GetTransaction'
import AppStyles from 'src/utils/useAppStyles'
import { FlatList, TouchableWithoutFeedback } from 'react-native-gesture-handler'
import TransactionAllocationRow from './TransactionAllocationRow'
import getAllocations from '../../../utils/getAllocations'

export default function SpendFromScreen() {
  const { colors }: any = useTheme()
  const { styles } = AppStyles()

  const navigation = useNavigation()
  const route = useRoute<RouteProp<RootStackParamList, 'Spend From'>>()
  const { transactionId } = route.params

  const navigateToCreate = () => navigation.navigate('Create Allocation', { transactionId: transactionId })

  const headerRight = () => {
    return (
      <TouchableWithoutFeedback onPress={navigateToCreate}>
        <Text style={styles.headerButtonText}>Add</Text>
      </TouchableWithoutFeedback>
    )
  }

  useLayoutEffect(() => navigation.setOptions({ headerRight: headerRight }))

  const { data } = useQuery<GetTransaction>(GET_TRANSACTION, { variables: { id: transactionId } })

  if (!data?.transaction) {
    return <ActivityIndicator color={colors.text} style={styles.activityIndicator} />
  }

  const allocations = getAllocations(data.transaction)

  return (
    <FlatList
      contentContainerStyle={styles.flatlistContentContainerStyle}
      data={allocations}
      renderItem={({ item }) => <TransactionAllocationRow allocation={item} transactionId={transactionId} />}
    />
  )
}