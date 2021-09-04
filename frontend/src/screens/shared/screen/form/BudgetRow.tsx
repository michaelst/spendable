import React, { Dispatch, SetStateAction } from 'react'
import {
  Text,
  TouchableHighlight,
  View
} from 'react-native'
import { ListBudgets_budgets } from 'src/screens/budgets/graphql/ListBudgets'
import { useTheme } from '@react-navigation/native'
import { Ionicons } from '@expo/vector-icons'
import formatCurrency from 'src/utils/formatCurrency'
import AppStyles from 'src/utils/useAppStyles'

type Props = {
  budget: ListBudgets_budgets,
  setBudgetId: Dispatch<SetStateAction<string>>
}

export default function BudgetRow({ budget, setBudgetId }: Props) {
  const { colors }: any = useTheme()
  const { styles, fontSize, padding } = AppStyles()

  return (
    <TouchableHighlight onPress={() => setBudgetId(budget.id)}>
      <View style={styles.row}>
        <View style={{ flex: 1 }}>
          <Text style={styles.text}>
            {budget.name}
          </Text>
        </View>

        <View style={{ flexDirection: "row" }}>
          <Text
            style={{
              color: budget.balance.isNegative() ? 'red' : colors.secondary,
              fontSize: fontSize,
              paddingRight: padding
            }}
          >
            {formatCurrency(budget.balance)}
          </Text>
          <Ionicons name='chevron-forward-outline' size={fontSize} color={colors.secondary} />
        </View>
      </View>
    </TouchableHighlight>
  )
}
