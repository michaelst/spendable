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
import {  useMutation } from '@apollo/client'
import { ListBudgets, ListBudgets_budgets } from './graphql/ListBudgets'
import { useTheme } from '@react-navigation/native'
import { Ionicons } from '@expo/vector-icons'
import formatCurrency from 'helpers/formatCurrency'
import { LIST_BUDGETS, DELETE_BUDGET } from 'components/budgets/queries'


type Props = {
  budget: ListBudgets_budgets,
}

export default function BudgetRow({ budget }: Props) {
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

  const navigation = useNavigation()
  const { colors }: any = useTheme()

  const navigateToBudget = () => navigation.navigate('Budget', { budgetId: budget.id })

  return (
    <TouchableHighlight onPress={navigateToBudget}>
      <Swipeable
        renderRightActions={renderRightActions}
        onSwipeableOpen={deleteBudget}
      >
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
      </Swipeable>
    </TouchableHighlight>
  )
}

const styles = StyleSheet.create({
  deleteText: {
    color: 'white',
    fontSize: 16,
    padding: 10,
    fontWeight: 'bold'
  },
  rightAction: {
    alignItems: 'center',
    flex: 1,
    flexDirection: 'row',
    backgroundColor: '#dd2c00',
    justifyContent: 'flex-end'
  },
})

const renderRightActions = () => {
  return (
    <RectButton style={[styles.rightAction, { backgroundColor: '#dd2c00' }]} >
      <Text style={styles.deleteText}> Delete </Text>
    </RectButton>
  )
}
