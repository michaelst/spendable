import React from 'react'
import { StyleSheet, View, Text } from 'react-native'
import { useTheme, RouteProp, useRoute, useNavigation } from '@react-navigation/native'
import { gql, useQuery } from '@apollo/client'
import { RootStackParamList } from 'components/budgets/Budgets'
import { StackNavigationProp } from '@react-navigation/stack'
import { GetBudget } from './graphql/GetBudget'

export const GET_BUDGET = gql`
  query GetBudget($id: ID!) {
    budget(id: $id) {
      id
      name
      balance
      goal
      recentAllocations {
        id
        amount
        transaction {
          name
          date
          bankTransaction {
            pending
          }
        }
      }
      allocationTemplateLines {
        id
        amount
        allocationTemplate {
          name
        }
      }
    }
  }
`


export default function BudgetRow() {
  const route = useRoute<RouteProp<RootStackParamList, 'Budget'>>()
  const navigation = useNavigation<StackNavigationProp<RootStackParamList, 'Budget'>>()
  const { budgetId } = route.params
  const { colors }: any = useTheme()

  const { data } = useQuery(GET_BUDGET, { variables: { id: budgetId } })

  navigation.setOptions({ headerTitle: data?.budget?.name ?? '' })

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
