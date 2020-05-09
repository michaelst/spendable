import React from 'react'
import { StyleSheet, View, Text } from 'react-native'
import { useTheme } from '@react-navigation/native'
import { RouteProp } from '@react-navigation/native'
import { RootStackParamList } from 'components/budgets/Budgets'
import { StackNavigationProp } from '@react-navigation/stack'

type BudgetScreenRouteProp = RouteProp<RootStackParamList, 'Budget'>
type BudgetScreenNavigationProp = StackNavigationProp<RootStackParamList, 'Budget'>

type Props = {
  navigation: BudgetScreenNavigationProp,
  route: BudgetScreenRouteProp
}

export default function BudgetRow({ route, navigation }: Props) {
  const { budgetId } = route.params
  const { colors }: any = useTheme()

  return (
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
          {budgetId}
        </Text>
      </View>
    </View>
  )
}
