import React, { useLayoutEffect } from 'react'
import {
  ActivityIndicator,
  SectionList,
  Text,
  View,
} from 'react-native'
import { RouteProp, useRoute, useNavigation } from '@react-navigation/native'
import { useQuery } from '@apollo/client'
import formatCurrency from 'src/utils/formatCurrency'
import TemplateRow, { TemplateRowItem } from '../components/TemplateRow'
import HeaderButton from 'src/components/HeaderButton'
import TransactionRow, { TransactionRowItem } from '../components/TransactionRow'
import { GetBudget, GetBudget_budget_allocationTemplateLines } from 'src/graphql/GetBudget'
import { GET_BUDGET } from 'src/queries'
import useAppStyles from 'src/utils/useAppStyles'

const Budget = () => {
  const { styles, colors } = useAppStyles()
  const navigation = useNavigation<NavigationProp>()
  const { params: { budgetId } } = useRoute<RouteProp<RootStackParamList, 'Budget'>>()

  const navigateToEdit = () => navigation.navigate('Edit Budget', { budgetId: budgetId })
  const headerRight = () => <HeaderButton title="Edit" onPress={navigateToEdit} />

  const { data } = useQuery<GetBudget>(GET_BUDGET, { variables: { id: budgetId }, fetchPolicy: 'cache-and-network' })

  if (data) {
    const headerTitle = (
      <View style={{ alignItems: 'center' }}>
        <Text style={styles.headerTitleText}>{formatCurrency(data.budget.balance)}</Text>
        <Text style={styles.secondaryText}>{data.budget.name}</Text>
      </View>
    )

    useLayoutEffect(() => navigation.setOptions({ headerTitle: headerTitle, headerRight: headerRight }))
  } else {
    useLayoutEffect(() => navigation.setOptions({ headerTitle: '', headerRight: headerRight }))
    return <ActivityIndicator color={colors.text} style={styles.activityIndicator} />
  }

  const allocationTemplateLines: TemplateRowItem[] = 
    [...data.budget.allocationTemplateLines]
    .sort((a, b) => b.amount.comparedTo(a.amount))
    .map(line => ({
      key: line.id,
      templateId: line.allocationTemplate.id,
      name: line.allocationTemplate.name,
      amount: line.amount,
      hideDelete: true,
      onPress: () => navigation.navigate('Template', { templateId: line.allocationTemplate.id })
    }))
  
  const recentAllocations: TransactionRowItem[] =
    [...data.budget.recentAllocations]
      .sort((a, b) => b.transaction.date - a.transaction.date)
      .map(allocation => ({
        key: allocation.id,
        transactionId: allocation.transaction.id,
        title: allocation.transaction.name,
        amount: allocation.amount,
        transactionDate: allocation.transaction.date,
        transactionReviewed: allocation.transaction.reviewed,
        onPress: () => navigation.navigate('Transaction', { transactionId: allocation.transaction.id })
      }))

  const sections = [
    {
      title: 'Templates',
      data: allocationTemplateLines,
      renderItem: ({ item }: { item: GetBudget_budget_allocationTemplateLines }) => <TemplateRow templateLine={item} />
    },
    {
      title: 'Recent Transactions',
      data: recentAllocations,
      renderItem: ({ item }: { item: TransactionRowItem }) => <TransactionRow item={item} />
    },
  ]

  return (
    <SectionList
      contentContainerStyle={styles.sectionListContentContainerStyle}
      sections={sections}
      renderSectionHeader={({ section: { title } }) => (
        <View style={styles.sectionHeader}>
          <Text style={styles.sectionHeaderText}>{title}</Text>
        </View>
      )}
      stickySectionHeadersEnabled={false}
    />
  )
}

export default Budget