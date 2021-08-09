import React from 'react'
import {
  Text,
  TouchableHighlight,
  View
} from 'react-native'
import { useNavigation } from '@react-navigation/native'
import { useTheme } from '@react-navigation/native'
import { Ionicons } from '@expo/vector-icons'
import formatCurrency from 'helpers/formatCurrency'
import Swipeable from 'react-native-gesture-handler/Swipeable'
import { RectButton } from 'react-native-gesture-handler'
import { useMutation } from '@apollo/client'
import AppStyles from 'constants/AppStyles'
import { DELETE_ALLOCATION } from '../queries'
import { GetTransaction_transaction_allocations } from '../graphql/GetTransaction'
import Decimal from 'decimal.js-light'

type Props = {
  allocation: GetTransaction_transaction_allocations,
  transactionId: string
}

export default function TransactionAllocationRow({ allocation, transactionId }: Props) {
  const navigation = useNavigation()
  const { colors }: any = useTheme()
  const { styles, fontSize } = AppStyles()

  const navigateToEdit = () => navigation.navigate('Edit Allocation', { allocationId: allocation.id, transactionId: transactionId })

  const [deleteAllocation] = useMutation(DELETE_ALLOCATION, {
    variables: { id: allocation.id },
    update(cache, { data: { deleteAllocation } }) {
      cache.evict({ id: 'Allocation:' + deleteAllocation.id })
      cache.gc()
    }
  })

  const renderRightActions = () => {
    return (
      <RectButton style={styles.deleteButton}>
        <Text style={styles.deleteButtonText}>Delete</Text>
      </RectButton>
    )
  }

  if (allocation.id === 'spendable') {
    return (
      <View style={styles.row}>
        <View style={{ flex: 1 }}>
          <Text style={styles.text}>
            {allocation.budget.name}
          </Text>
        </View>

        <View style={{ flexDirection: "row" }}>
          <Text style={styles.rightText} >
            {formatCurrency(allocation.amount)}
          </Text>
        </View>
      </View>
    )
  }

  return (
    <TouchableHighlight onPress={navigateToEdit}>
      <Swipeable
        renderRightActions={renderRightActions}
        onSwipeableOpen={deleteAllocation}
      >
        <View style={styles.row}>
          <View style={{ flex: 1 }}>
            <Text style={styles.text}>
              {allocation.budget.name}
            </Text>
          </View>

          <View style={{ flexDirection: "row" }}>
            <Text style={styles.rightText} >
              {formatCurrency(allocation.amount)}
            </Text>
            <Ionicons name='chevron-forward-outline' size={fontSize} color={colors.secondary} />
          </View>
        </View>
      </Swipeable>
    </TouchableHighlight>
  )
}
