import React from 'react'
import {
  ActivityIndicator,
  RefreshControl,
  SectionList,
  StyleSheet,
  Text
} from 'react-native'
import Constants from 'expo-constants'
import { useQuery } from '@apollo/client'
import { ListBudgets } from 'components/budgets/graphql/ListBudgets'
import BudgetRow from './BudgetRow'
import { useTheme, useNavigation } from '@react-navigation/native'
import { LIST_BUDGETS } from 'components/budgets/queries'
import { StackNavigationProp } from '@react-navigation/stack'
import { RootStackParamList } from 'components/budgets/Budgets'
import { TouchableWithoutFeedback } from 'react-native-gesture-handler'

export default function BudgetsScreen() {
  const { colors }: any = useTheme()

  const navigation = useNavigation<StackNavigationProp<RootStackParamList, 'Budgets'>>()

  const styles = StyleSheet.create({
    container: {
      flex: 1,
      marginTop: Constants.statusBarHeight,
    },
    activityIndicator: {
      flex: 1,
      alignItems: 'center',
      justifyContent: 'center',
    },
    headerText: {
      backgroundColor: colors.background,
      color: colors.secondary,
      padding: 20,
      paddingBottom: 5
    }
  })

  const { data, loading, refetch } = useQuery<ListBudgets>(LIST_BUDGETS)
  if (loading && !data) return <ActivityIndicator color={colors.text} style={styles.activityIndicator} />


  const headerRight = () => {
    return (
      <TouchableWithoutFeedback onPress={() => navigation.navigate('Create Budget')}>
        <Text style={{ color: colors.primary, fontSize: 20, paddingRight: 20 }}>Add</Text>
      </TouchableWithoutFeedback>
    )
  }

  navigation.setOptions({headerRight: headerRight})

  const budgets = data?.budgets.filter(budget => !budget.goal).sort((a, b) => b.balance.comparedTo(a.balance)) ?? []
  const goals = data?.budgets.filter(budget => budget.goal).sort((a, b) => b.balance.comparedTo(a.balance)) ?? []

  const listData = [
    { title: "Expenses", data: budgets },
    { title: "Goals", data: goals }
  ]

  return (
    <SectionList
      contentContainerStyle={{ paddingBottom: 40 }}
      sections={listData}
      renderItem={({ item }) => <BudgetRow budget={item} />}
      renderSectionHeader={({ section: { title } }) => <Text style={styles.headerText}>{title}</Text>}
      stickySectionHeadersEnabled={false}
      refreshControl={<RefreshControl refreshing={loading} onRefresh={refetch} />}
    />
  )
}