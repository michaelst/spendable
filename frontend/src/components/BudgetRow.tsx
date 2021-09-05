import React from 'react'
import {
  Text,
  TouchableHighlight,
  View
} from 'react-native'
import { RectButton } from 'react-native-gesture-handler'
import Swipeable from 'react-native-gesture-handler/Swipeable'
import { useMutation } from '@apollo/client'
import formatCurrency from 'src/utils/formatCurrency'
import useAppStyles from 'src/utils/useAppStyles'
import { StyleSheet } from 'react-native'
import { DELETE_BUDGET } from 'src/queries'

export type BudgetRowItem = {
  id: string
  title: string
  amount: Decimal
  subText: string
  hideDelete?: boolean
  onPress: () => void
}

type BudgetRowProps = {
  item: BudgetRowItem
}

const BudgetRow = ({item}: BudgetRowProps) => {
  const { styles } = useAppStyles()

  const [deleteBudget] = useMutation(DELETE_BUDGET, {
    variables: { id: item.id },
    update(cache, { data: { deleteBudget } }) {
      cache.evict({ id: 'Budget:' + deleteBudget.id })
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
    <Swipeable
      renderRightActions={renderRightActions}
      onSwipeableOpen={deleteBudget}
    >
      <Row item={item} />
    </Swipeable>
  )
}

const Row = ({item: { title, amount, subText, onPress }}: BudgetRowProps) => {
  const { styles } = useAppStyles()
  const amountTextStyle = amount.isNegative() ? styles.dangerText : styles.text

  return (
    <TouchableHighlight onPress={onPress}>
      <View style={styles.row}>
        <View>
          <Text style={styles.headerTitleText}>{title}</Text>
        </View>
        <View>
          <Text style={{ ...styles.detailText, ...amountTextStyle }}>{formatCurrency(amount)}</Text>
          <Text style={styles.detailSubText}>{subText}</Text>
        </View>
      </View>
    </TouchableHighlight >
  )
}

export default BudgetRow