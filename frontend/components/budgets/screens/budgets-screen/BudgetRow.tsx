import React from 'react'
import {
  StyleSheet,
  Text,
  TouchableHighlight,
  View
} from 'react-native'
import { ListBudgets_budgets } from 'components/budgets/graphql/ListBudgets'
import { useTheme } from '@react-navigation/native'
import Decimal from 'decimal.js-light'
import formatCurrency from 'helpers/formatCurrency'

type Props = {
  budget: ListBudgets_budgets,
  onPress: () => void
}

export default function BudgetRow({ budget, onPress }: Props) {
  const { colors }: any = useTheme()

  const balance = new Decimal(budget.balance)

  return (
    <TouchableHighlight onPress={onPress}>
      <View
        style={{
          flexDirection: 'row',
          padding: 20,
          alignItems: 'center',
          backgroundColor: colors.card,
          borderBottomColor: colors.border,
          borderBottomWidth: StyleSheet.hairlineWidth
        }}
      >
        <View style={{ flex: 1 }}>
          <Text style={{ color: colors.text, fontSize: 20 }}>
            {budget.name}
          </Text>
        </View>
        <View style={{ flex: 1 }}>
          <Text
            style={{
              color: balance.isNegative() ? 'red' : colors.secondary,
              textAlign: 'right',
              fontSize: 20
            }}
          >
            {formatCurrency(balance)}
          </Text>
        </View>
      </View>
    </TouchableHighlight>
  )
}
