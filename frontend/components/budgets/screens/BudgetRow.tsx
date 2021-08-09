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
import { ListBudgets, ListBudgets_budgets } from 'components/budgets/graphql/ListBudgets'
import { useTheme } from '@react-navigation/native'
import { Ionicons } from '@expo/vector-icons'
import formatCurrency from 'helpers/formatCurrency'
import { LIST_BUDGETS, DELETE_BUDGET } from 'components/budgets/queries'
import AppStyles from 'constants/AppStyles'

type Props = {
  budget: ListBudgets_budgets,
}

export default function BudgetRow({ budget }: Props) {
  const navigation = useNavigation()
  const { colors }: any = useTheme()
  const { styles, fontSize, padding } = AppStyles()

  const navigateToBudget = () => navigation.navigate('Expense', { budgetId: budget.id })

  const [deleteBudget] = useMutation(DELETE_BUDGET, {
    variables: { id: budget.id },
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

  return (
    <TouchableHighlight onPress={navigateToBudget}>
      <Swipeable
        renderRightActions={renderRightActions}
        onSwipeableOpen={deleteBudget}
      >
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
      </Swipeable>
    </TouchableHighlight>
  )
}