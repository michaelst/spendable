import React from 'react'
import {
  StyleSheet,
  Text,
  TouchableHighlight,
  View
} from 'react-native'
import { useNavigation } from '@react-navigation/native'
import { ListBudgets_budgets } from 'components/budgets/graphql/ListBudgets'
import { useTheme } from '@react-navigation/native'
import { Ionicons } from '@expo/vector-icons'
import Decimal from 'decimal.js-light'
import formatCurrency from 'helpers/formatCurrency'

type Props = {
  budget: ListBudgets_budgets,
}

export default function BudgetRow({ budget }: Props) {
  const navigation = useNavigation()
  const { colors }: any = useTheme()

  const balance = new Decimal(budget.balance)

  const navigateToBudget = () => navigation.navigate('Budget', { budgetId: budget.id })

  return (
    <TouchableHighlight onPress={navigateToBudget}>
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

        <View style={{ flexDirection: "row" }}>
          <Text
            style={{
              color: balance.isNegative() ? 'red' : colors.secondary,
              fontSize: 18,
              paddingRight: 8
            }}
          >
            {formatCurrency(balance)}
          </Text>
          <Ionicons name='ios-arrow-forward' size={18} color={colors.secondary} />
        </View>
      </View>
    </TouchableHighlight>
  )
}
