import React from 'react'
import {
  StyleSheet,
  Text,
  TouchableHighlight,
  View
} from 'react-native'
import { useNavigation } from '@react-navigation/native'
import { RectButton } from 'react-native-gesture-handler'
import Swipeable from 'react-native-gesture-handler/Swipeable'
import { useMutation } from '@apollo/client'
import formatCurrency from 'src/utils/formatCurrency'
import { DELETE_TRANSACTION, MAIN_QUERY } from '../queries'
import { DateTime } from 'luxon'
import useAppStyles from 'src/utils/useAppStyles'
import { FontAwesomeIcon } from '@fortawesome/react-native-fontawesome'
import { faCheckCircle, faChevronRight } from '@fortawesome/free-solid-svg-icons'

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
  const { styles } = useAppStyles()

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

  const componentStyles = StyleSheet.create({
    titleText: {
      ...styles.text,
      paddingRight: baseUnit * 2
    },
    amountTextStyle: {
      ...styles.text,
      color: amount.isNegative() ? colors.danger : colors.secondary,
      paddingRight: baseUnit / 2
    }
  })

  return (
    <TouchableHighlight onPress={onPress}>
      <View style={styles.row}>
        <View style={styles.flex}>
          <Text numberOfLines={1} style={componentStyles.titleText}>
            {title}
          </Text>
          <Text style={styles.secondaryText}>
            {DateTime.fromJSDate(transactionDate).toLocaleString(DateTime.DATE_MED)}
          </Text>
        </View>

        <View style={{ flexDirection: "row" }}>
          <Text style={componentStyles.amountTextStyle} >
            {formatCurrency(amount)}
          </Text>
          {transactionReviewed && <FontAwesomeIcon icon={faCheckCircle} size={fontSize} color={colors.secondary} />}
          <FontAwesomeIcon icon={faChevronRight} size={fontSize} color={colors.secondary} />
        </View>
      </View>
    </TouchableHighlight >
  )
}

export default TransactionRow