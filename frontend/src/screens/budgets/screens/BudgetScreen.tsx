import React, { useLayoutEffect } from 'react'
import {
  ActivityIndicator,
  SectionList,
  Text,
  View,
} from 'react-native'
import { useTheme, RouteProp, useRoute, useNavigation } from '@react-navigation/native'
import { useQuery } from '@apollo/client'
import { RootStackParamList } from 'src/screens/budgets/Budgets'
import { GET_BUDGET } from 'src/screens/budgets/queries'
import formatCurrency from 'src/utils/formatCurrency'
import {
  GetBudget,
  GetBudget_budget_recentAllocations as Allocation,
  GetBudget_budget_allocationTemplateLines as AllocationTemplateLine
} from 'src/screens/budgets/graphql/GetBudget'
import TemplateRow from './TemplateRow'
import AppStyles from 'src/utils/useAppStyles'
import HeaderButton from 'src/screens/shared/components/HeaderButton'
import TransactionRow from './TransactionRow'

export default function BudgetScreen() {
  const { colors }: any = useTheme()
  const { styles } = AppStyles()

  const navigation = useNavigation()
  const route = useRoute<RouteProp<RootStackParamList, 'Expense'>>()
  const { budgetId } = route.params

  const navigateToEdit = () => navigation.navigate('Edit Expense', { budgetId: budgetId })
  const headerRight = () => <HeaderButton title="Edit" onPress={navigateToEdit} />

  const { data } = useQuery<GetBudget>(GET_BUDGET, { variables: { id: budgetId }, fetchPolicy: 'cache-and-network' })

  if (data?.budget) {
    const headerTitle = () => {
      return (
        <View style={{ alignItems: 'center' }}>
          <Text style={styles.headerTitleText}>{formatCurrency(data.budget.balance)}</Text>
          <Text style={styles.secondaryText}>{data.budget.name}</Text>
        </View>
      )
    }

    useLayoutEffect(() => navigation.setOptions({ headerTitle: headerTitle, headerRight: headerRight }))
  } else {
    useLayoutEffect(() => navigation.setOptions({ headerTitle: '', headerRight: headerRight }))
    return <ActivityIndicator color={colors.text} style={styles.activityIndicator} />
  }

  const allocationTemplateLines = [...data.budget.allocationTemplateLines].sort((a, b) => b.amount.comparedTo(a.amount))
  const recentAllocations = [...data.budget.recentAllocations].sort((a, b) => b.transaction.date - a.transaction.date)

  const sections = [
    {
      title: 'Templates',
      data: allocationTemplateLines,
      renderItem: ({ item }: { item: AllocationTemplateLine }) => <TemplateRow templateLine={item} />
    },
    {
      title: 'Recent Transactions',
      data: recentAllocations,
      renderItem: ({ item }: { item: Allocation }) => <TransactionRow allocation={item} />
    },
  ]

  return (
    <SectionList
      contentContainerStyle={styles.sectionListContentContainerStyle}
      sections={sections}
      renderSectionHeader={({ section: { title } }) => <Text style={styles.sectionHeaderText}>{title}</Text>}
      stickySectionHeadersEnabled={false}
    />
  )
}