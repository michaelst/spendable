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
  const { styles, fontSize } = AppStyles()

  const navigateToBudget = () => navigation.navigate('Expense', { budgetId: budget.id })

  const [deleteBudget] = useMutation(DELETE_BUDGET, {
    variables: { id: budget.id },
    update(cache, { data: { deleteBudget } }) {
      const data = cache.readQuery<ListBudgets | null>({ query: LIST_BUDGETS })

      cache.writeQuery({
        query: LIST_BUDGETS,
        data: { budgets: data?.budgets.filter(budget => budget.id !== deleteBudget.id) }
      })
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
                paddingRight: 8
              }}
            >
              {formatCurrency(budget.balance)}
            </Text>
            <Ionicons name='ios-arrow-forward' size={fontSize} color={colors.secondary} />
          </View>
        </View>
      </Swipeable>
    </TouchableHighlight>
  )
}