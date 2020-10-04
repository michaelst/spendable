import React, { Dispatch, SetStateAction } from 'react'
import {
  StyleSheet,
  Text,
  TouchableHighlight,
  View
} from 'react-native'
import { ListBudgets_budgets } from 'components/budgets/graphql/ListBudgets'
import { useTheme } from '@react-navigation/native'
import { Ionicons } from '@expo/vector-icons'
import formatCurrency from 'helpers/formatCurrency'

type Props = {
  budget: ListBudgets_budgets,
  setBudgetId: Dispatch<SetStateAction<string>>
}

export default function BudgetRow({ budget, setBudgetId }: Props) {
  const { colors }: any = useTheme()

  return (
    <TouchableHighlight onPress={() => setBudgetId(budget.id)}>
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
              color: budget.balance.isNegative() ? 'red' : colors.secondary,
              fontSize: 18,
              paddingRight: 8
            }}
          >
            {formatCurrency(budget.balance)}
          </Text>
          <Ionicons name='ios-arrow-forward' size={18} color={colors.secondary} />
        </View>
      </View>
    </TouchableHighlight>
  )
}
