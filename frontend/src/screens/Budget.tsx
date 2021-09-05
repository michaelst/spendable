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
import TemplateRow from '../components/TemplateRow'
import HeaderButton from 'src/components/HeaderButton'
import TransactionRow, { TransactionRowItem } from '../components/TransactionRow'
import { GetBudget } from 'src/graphql/GetBudget'
import { GET_BUDGET } from 'src/queries'
import { AllocationTemplateLine } from './settings/graphql/AllocationTemplateLine'
import useAppStyles from 'src/utils/useAppStyles'
import { Allocation } from 'src/graphql/Allocation'

const Budget = () => {
  const { styles, colors } = useAppStyles()
  const navigation = useNavigation<NavigationProp>()
  const { params: { budgetId } } = useRoute<RouteProp<RootStackParamList, 'Expense'>>()

  const navigateToEdit = () => navigation.navigate('Edit Expense', { budgetId: budgetId })
  const headerRight = <HeaderButton title="Edit" onPress={navigateToEdit} />

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

  const allocationTemplateLines = [...data.budget.allocationTemplateLines].sort((a, b) => b.amount.comparedTo(a.amount))
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

export default Budget