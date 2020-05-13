import React from 'react'
import {
  ActivityIndicator,
  RefreshControl,
  SectionList,
  StyleSheet,
  Text
} from 'react-native'
import Constants from 'expo-constants'
import { gql, useQuery } from '@apollo/client'
import { ListBudgets } from './graphql/ListBudgets'
import BudgetRow from './BudgetRow'
import { useTheme } from '@react-navigation/native'

export const LIST_BUDGETS = gql`
  query ListBudgets {
    budgets {
      id
      name
      balance
      goal
    }
  }
`

export default function BudgetsScreen() {
  const { colors }: any = useTheme()

  const { data, loading, refetch } = useQuery<ListBudgets>(LIST_BUDGETS, {
  })

  const budgets = data?.budgets.filter(budget => !budget.goal).sort((a ,b) => b.balance.comparedTo(a.balance)) ?? []
  const goals = data?.budgets.filter(budget => budget.goal).sort((a ,b) => b.balance.comparedTo(a.balance)) ?? []

  const listData = [
    { title: "Budgets", data: budgets },
    { title: "Goals", data: goals }
  ]

  if (loading && !data) return <ActivityIndicator color={colors.text} style={styles.activityIndicator} />

  return (
    <SectionList
      contentContainerStyle={{
        paddingBottom: 40
      }}
      sections={listData}
      renderItem={({ item }) => <BudgetRow budget={item} />}
      renderSectionHeader={({ section: { title } }) => (
        <Text
          style={{
            backgroundColor: colors.background,
            color: colors.secondary,
            padding: 20,
            paddingBottom: 5
          }}
        >
          {title}
        </Text>
      )}
      stickySectionHeadersEnabled={false}
      refreshControl={
        <RefreshControl refreshing={loading} onRefresh={refetch} />
      }
    />
  )
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    marginTop: Constants.statusBarHeight,
  },
  activityIndicator: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  }
})