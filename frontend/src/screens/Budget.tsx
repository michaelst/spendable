import React, { useContext, useLayoutEffect } from 'react'
import {
  SectionList,
  Text,
  View,
} from 'react-native'
import { RouteProp, useRoute, useNavigation } from '@react-navigation/native'
import { useQuery } from '@apollo/client'
import TemplateRow, { TemplateRowItem } from '../components/TemplateRow'
import HeaderButton from 'src/components/HeaderButton'
import TransactionRow, { TransactionRowItem } from '../components/TransactionRow'
import { GetBudget } from 'src/graphql/GetBudget'
import { GET_BUDGET } from 'src/queries'
import useAppStyles from 'src/hooks/useAppStyles'
import formatCurrency from 'src/utils/formatCurrency'
import Row, { RowProps } from 'src/components/Row'
import SettingsContext from 'src/context/Settings'
import { DateTime } from 'luxon'

const Budget = () => {
  const { activeMonth } = useContext(SettingsContext)
  const { styles } = useAppStyles()
  const navigation = useNavigation<NavigationProp>()
  const { params: { budgetId } } = useRoute<RouteProp<RootStackParamList, 'Budget'>>()

  const activeMonthIsCurrentMonth = DateTime.now().startOf('month').equals(activeMonth)

  const navigateToEdit = () => navigation.navigate('Edit Budget', { budgetId: budgetId })
  const headerRight = () => <HeaderButton title="Edit" onPress={navigateToEdit} />

  const { data } = useQuery<GetBudget>(GET_BUDGET, {
    variables: { 
      id: budgetId, 
      startDate: activeMonth.toFormat('yyyy-MM-dd') ,
      endDate: activeMonth.endOf('month').toFormat('yyyy-MM-dd') 
    },
    fetchPolicy: 'cache-and-network'
  })

  useLayoutEffect(() => navigation.setOptions({ headerTitle: data?.budget.name, headerRight: headerRight }))

  if (!data) return null


  const balance = {
    key: 'balance',
    leftSide: 'Balance',
    rightSide: formatCurrency(data.budget.balance)
  }

  const spent = {
    key: 'spent',
    leftSide: 'Spent',
    rightSide: formatCurrency(data.budget.spent)
  }

  const detailLines: RowProps[] = []

  if (activeMonthIsCurrentMonth) detailLines.push(balance)
  detailLines.push(spent)

  const allocationTemplateLines: TemplateRowItem[] =
    [...data.budget.budgetAllocationTemplateLines]
      .sort((a, b) => b.amount.comparedTo(a.amount))
      .map(line => ({
        key: line.id,
        templateId: line.budgetAllocationTemplate.id,
        name: line.budgetAllocationTemplate.name,
        amount: line.amount,
        hideDelete: true,
        onPress: () => navigation.navigate('Template', { templateId: line.budgetAllocationTemplate.id })
      }))

  const recentAllocations: TransactionRowItem[] =
    [...data.budget.budgetAllocations]
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
      title: activeMonth.toFormat('MMM yyyy'),
      data: detailLines,
      renderItem: ({ item: props }: { item: RowProps }) => <Row {...props} />
    },
    activeMonthIsCurrentMonth && {
      title: 'Templates',
      data: allocationTemplateLines,
      renderItem: ({ item }: { item: TemplateRowItem }) => <TemplateRow item={item} />
    },
    {
      title: 'Recent Transactions',
      data: recentAllocations,
      renderItem: ({ item }: { item: TransactionRowItem }) => <TransactionRow item={item} />
    },
  ]
    .filter(section => section && section.data.length > 0)

  return (
    <SectionList
      sections={sections}
      renderSectionHeader={({ section: { title } }) => (
        <View style={styles.sectionHeader}>
          <Text style={styles.sectionHeaderText}>{title}</Text>
        </View>
      )}
      stickySectionHeadersEnabled={false}
      contentInsetAdjustmentBehavior="automatic"
    />
  )
}

export default Budget