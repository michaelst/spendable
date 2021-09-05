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
import formatCurrency from 'src/utils/formatCurrency'
import { DELETE_BUDGET } from 'src/screens/budgets/queries'
import useAppStyles from 'src/utils/useAppStyles'
import { StyleSheet } from 'react-native'

export type BudgetRowItem = {
  id: string
  title: string
  amount: Decimal
  subText: string
}

type BudgetRowProps = {
  item: BudgetRowItem
}

export default function BudgetRow({item}: BudgetRowProps) {
  const { styles } = useStyles()

  const [deleteBudget] = useMutation(DELETE_BUDGET, {
    variables: { id: item.id },
    update(cache, { data: { deleteBudget } }) {
      cache.evict({ id: 'Budget:' + deleteBudget.id })
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

  // no swipe actions available on Spendable
  if (item.id === 'spendable') return <Row item={item} />

  return (
    <Swipeable
      renderRightActions={renderRightActions}
      onSwipeableOpen={deleteBudget}
    >
      <Row item={item} />
    </Swipeable>
  )
}

const Row = ({item: { id, title, amount, subText }}: BudgetRowProps) => {
  const navigation = useNavigation<UseNavigationProp>()
  const { styles } = useStyles()
  const amountTextStyle = amount.isNegative() ? styles.dangerText : styles.text

  const navigateToBudget = () => navigation.navigate('Expense', { budgetId: id })

  return (
    <TouchableHighlight onPress={navigateToBudget}>
      <View style={styles.rowView}>
        <View>
          <Text style={styles.headerTitleText}>{title}</Text>
        </View>
        <View>
          <Text style={{ ...styles.amountText, ...amountTextStyle }}>{formatCurrency(amount)}</Text>
          <Text style={styles.budgetDetailSubText}>{subText}</Text>
        </View>
      </View>
    </TouchableHighlight >
  )
}

const useStyles = () => {
  const { styles, colors, baseUnit } = useAppStyles()

  const screenStyles = StyleSheet.create({
    ...styles,
    rowView: {
      flexDirection: 'row',
      alignItems: 'center',
      justifyContent: 'space-between',
      borderBottomColor: colors.border,
      borderBottomWidth: StyleSheet.hairlineWidth,
      paddingVertical: baseUnit * 3,
      marginHorizontal: baseUnit * 2
    },
    amountText: {
      textAlign: 'right',
      marginBottom: baseUnit / 4
    },
    budgetDetailSubText: {
      ...styles.subText,
      textAlign: 'right'
    }
  })

  return {
    styles: screenStyles
  }
}