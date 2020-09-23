import React, { useLayoutEffect } from 'react'
import {
  ActivityIndicator,
  SectionList,
  Text,
  StyleSheet,
  View,
} from 'react-native'
import { useTheme, RouteProp, useRoute, useNavigation } from '@react-navigation/native'
import { useQuery } from '@apollo/client'
import { RootStackParamList } from 'components/budgets/Budgets'
import { Ionicons } from '@expo/vector-icons'
import { GET_BUDGET } from 'components/budgets/queries'
import formatCurrency from 'helpers/formatCurrency'
import {
  GetBudget,
  GetBudget_budget_recentAllocations as Allocation,
  GetBudget_budget_allocationTemplateLines as AllocationTemplateLine
} from 'components/budgets/graphql/GetBudget'
import { TouchableWithoutFeedback } from 'react-native-gesture-handler'
import TemplateRow from './TemplateRow'

export default function BudgetRow() {
  const { colors }: any = useTheme()

  const navigation = useNavigation()
  const route = useRoute<RouteProp<RootStackParamList, 'Expense'>>()
  const { budgetId } = route.params

  const navigateToEdit = () => navigation.navigate('Edit Expense', { budgetId: budgetId })
  
  const { data } = useQuery<GetBudget>(GET_BUDGET, { variables: { id: budgetId } })

  const headerRight = () => {
    return (
      <TouchableWithoutFeedback onPress={navigateToEdit}>
        <Text style={{ color: colors.primary, fontSize: 18, paddingRight: 18 }}>Edit</Text>
      </TouchableWithoutFeedback>
    )
  }

  if (data?.budget) {
    const headerTitle = () => {
      return (
        <View style={{ alignItems: 'center' }}>
          <Text style={{ color: colors.text, fontWeight: 'bold', fontSize: 18 }}>{formatCurrency(data.budget.balance)}</Text>
          <Text style={{ color: colors.secondary, fontSize: 12 }}>{data.budget.name}</Text>
        </View>
      )
    }

    useLayoutEffect(() => navigation.setOptions({ headerTitle: headerTitle, headerRight: headerRight }))
  } else {
    useLayoutEffect(() => navigation.setOptions({ headerTitle: '', headerRight: headerRight }))
    return <ActivityIndicator color={colors.text} style={styles.activityIndicator} />
  }

  const sections = [
    {
      title: 'Templates',
      data: data.budget.allocationTemplateLines,
      renderItem: ({ item }: { item: AllocationTemplateLine }) => <TemplateRow templateLine={item} />
    },
    {
      title: 'Recent Transactions',
      data: data.budget.recentAllocations,
      renderItem: ({ item }: { item: Allocation }) => <Text style={{ color: 'white' }}>{item.transaction.name}</Text>
    },
  ]

  return (
    <SectionList
      contentContainerStyle={{
        paddingBottom: 36
      }}
      sections={sections}
      renderSectionHeader={({ section: { title } }) => (
        <Text
          style={{
            backgroundColor: colors.background,
            color: colors.secondary,
            padding: 18,
            paddingBottom: 5
          }}
        >
          {title}
        </Text>
      )}
      stickySectionHeadersEnabled={false}
    />
  )
}

const styles = StyleSheet.create({
  activityIndicator: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  }
})