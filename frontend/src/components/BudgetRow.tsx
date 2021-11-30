import React from 'react'
import {
  Text,
  TouchableHighlight,
  View
} from 'react-native'
import { useMutation } from '@apollo/client'
import formatCurrency from 'src/utils/formatCurrency'
import useAppStyles from 'src/hooks/useAppStyles'
import { DELETE_BUDGET } from 'src/queries'
import { DeleteBudget } from 'src/graphql/DeleteBudget'
import SwipeableRow from './SwipeableRow'

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
  const [deleteBudget] = useMutation(DELETE_BUDGET, {
    variables: { id: item.id },
    update(cache, { data }) {
      const { deleteBudget }: DeleteBudget = data
      cache.evict({ id: 'Budget:' + deleteBudget?.result?.id })
      cache.gc()
    }
  })

  if (item.hideDelete) return <Row item={item} />

  return (
    <SwipeableRow onPress={deleteBudget}>
      <Row item={item} />
    </SwipeableRow>
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