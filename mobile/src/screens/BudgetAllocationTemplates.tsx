import React, { useLayoutEffect } from 'react'
import { RefreshControl, } from 'react-native'
import { useNavigation } from '@react-navigation/native'
import { FlatList } from 'react-native-gesture-handler'
import { useQuery } from '@apollo/client'
import TemplateRow, { TemplateRowItem } from '../components/TemplateRow'
import Decimal from 'decimal.js-light'
import HeaderButton from 'src/components/HeaderButton'
import { LIST_BUDGET_ALLOCATION_TEMPLATES } from 'src/queries'
import { ListBudgetAllocationTemplates } from 'src/graphql/ListBudgetAllocationTemplates'

const BudgetAllocationTemplates = () => {
  const navigation = useNavigation<NavigationProp>()

  const navigateToCreateTemplate = () => navigation.navigate('Create Template')
  const headerRight = () => <HeaderButton title="Add" onPress={navigateToCreateTemplate} />
  useLayoutEffect(() => navigation.setOptions({ headerRight: headerRight }))

  const { data, loading, refetch } = useQuery<ListBudgetAllocationTemplates>(LIST_BUDGET_ALLOCATION_TEMPLATES)

  const templates: TemplateRowItem[] =
    [...data?.budgetAllocationTemplates ?? []]
      .sort((a, b) => {
        const aAllocated = a.budgetAllocationTemplateLines.reduce((acc, line) => acc.add(line.amount), new Decimal('0'))
        const bAllocated = b.budgetAllocationTemplateLines.reduce((acc, line) => acc.add(line.amount), new Decimal('0'))

        return bAllocated.comparedTo(aAllocated)
      })
      .map(template => {
        const allocated = template.budgetAllocationTemplateLines.reduce((acc, line) => acc.add(line.amount), new Decimal('0'))
        
        return {
          key: template.id,
          templateId: template.id,
          name: template.name,
          amount: allocated,
          onPress: () => navigation.navigate('Template', { templateId: template.id })
        }
      })

  return (
    <FlatList
      data={templates}
      renderItem={({ item }) => <TemplateRow item={item} />}
      refreshControl={<RefreshControl refreshing={loading} onRefresh={refetch} />}
      contentInsetAdjustmentBehavior="automatic"
    />
  )
}

export default BudgetAllocationTemplates