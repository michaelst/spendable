import React from 'react'
import {
  ActivityIndicator,
  RefreshControl,
  SafeAreaView,
  SectionList,
  StyleSheet,
  Text
} from 'react-native'
import { StackNavigationProp } from '@react-navigation/stack'
import Constants from 'expo-constants'
import { gql, useQuery } from '@apollo/client'
import { ListBudgets } from 'components/budgets/graphql/ListBudgets'
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

  const { data, loading, refetch, networkStatus } = useQuery<ListBudgets>(LIST_BUDGETS, {
    notifyOnNetworkStatusChange: true
  })

  const budgets = data?.budgets.filter(budget => !budget.goal) ?? []
  const goals = data?.budgets.filter(budget => budget.goal) ?? []

  const listData = [
    { title: "Budgets", data: budgets },
    { title: "Goals", data: goals }
  ]

  if (loading && !data) return <ActivityIndicator color={colors.text} style={styles.activityIndicator} />

  return (
    <SectionList
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
        <RefreshControl refreshing={networkStatus === 4} onRefresh={refetch} />
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