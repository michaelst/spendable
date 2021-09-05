import React from 'react'
import {
  Text,
  TouchableHighlight,
  View
} from 'react-native'
import { useNavigation } from '@react-navigation/native'
import { RectButton } from 'react-native-gesture-handler'
import Swipeable from 'react-native-gesture-handler/Swipeable'
import { useMutation } from '@apollo/client'
import { Ionicons } from '@expo/vector-icons'
import formatCurrency from 'src/utils/formatCurrency'
import AppStyles from 'src/utils/useAppStyles'
import { DELETE_TRANSACTION, MAIN_QUERY } from '../queries'
import { DateTime } from 'luxon'
import useAppStyles from 'src/utils/useAppStyles'

export type TransactionRowItem = {
  key: string
  transactionId: string
  title: string | null
  amount: Decimal
  transactionDate: Date
  transactionReviewed: boolean
  hideDelete?: boolean
  onPress: () => void
}

type TransactionRowProps = {
  item: TransactionRowItem
}

const TransactionRow = ({ item }: TransactionRowProps) => {
  const navigation = useNavigation<NavigationProp>()
  const { styles } = AppStyles()

  const navigateToTransaction = () => navigation.navigate('Transaction', { transactionId: item.transactionId })

  const [deleteTransaction] = useMutation(DELETE_TRANSACTION, {
    variables: { id: item.transactionId },
    refetchQueries: [{ query: MAIN_QUERY }],
    update(cache, { data: { deleteTransaction } }) {
      cache.evict({ id: 'Transaction:' + deleteTransaction.id })
      cache.gc()
    }
  })

  if (item.hideDelete) return <Row item={item} />

  const renderRightActions = () => {
    return (
      <RectButton style={styles.deleteButton}>
        <Text style={styles.deleteButtonText}>Delete</Text>
      </RectButton>
    )
  }

  return (
    <TouchableHighlight onPress={navigateToTransaction}>
      <Swipeable
        renderRightActions={renderRightActions}
        onSwipeableOpen={deleteTransaction}
      >
        <Row item={item} />
      </Swipeable>
    </TouchableHighlight>
  )
}

const Row = ({ item: { title, amount, transactionDate, transactionReviewed, onPress } }: TransactionRowProps) => {
  const { styles, baseUnit, fontSize, colors } = useAppStyles()
  const amountTextStyle = amount.isNegative() ? styles.dangerText : styles.text

  return (
    <TouchableHighlight onPress={onPress}>
      <View style={styles.row}>
        <View>
          <Text numberOfLines={1} style={{ ...styles.text, ...{ paddingRight: baseUnit } }}>
            {title}
          </Text>
          <Text style={styles.secondaryText}>
            {DateTime.fromJSDate(transactionDate).toLocaleString(DateTime.DATE_MED)}
          </Text>
        </View>

        <View style={{ flexDirection: "row" }}>
          <Text style={amountTextStyle} >
            {formatCurrency(amount)}
          </Text>
          {transactionReviewed && <Ionicons name='checkmark-circle-outline' size={fontSize} color={colors.secondary} />}
          <Ionicons name='chevron-forward-outline' size={fontSize} color={colors.secondary} />
        </View>
      </View>
    </TouchableHighlight >
  )
}

export default TransactionRow