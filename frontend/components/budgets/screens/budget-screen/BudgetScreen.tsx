import React from 'react'
import { View, StyleSheet, Text, SectionList, ActivityIndicator } from 'react-native'
import { useTheme, RouteProp, useRoute, useNavigation } from '@react-navigation/native'
import { useQuery } from '@apollo/client'
import { RootStackParamList } from 'components/budgets/Budgets'
import { StackNavigationProp } from '@react-navigation/stack'
import { GET_BUDGET } from 'components/budgets/queries'
import formatCurrency from 'helpers/formatCurrency'
import { 
  GetBudget, 
  GetBudget_budget_recentAllocations as Allocation,
  GetBudget_budget_allocationTemplateLines as AllocationTemplateLine
} from 'components/budgets/graphql/GetBudget'

export default function BudgetRow() {
  const route = useRoute<RouteProp<RootStackParamList, 'Budget'>>()
  const navigation = useNavigation<StackNavigationProp<RootStackParamList, 'Budget'>>()
  const { budgetId } = route.params
  const { colors }: any = useTheme()

  const { data } = useQuery<GetBudget>(GET_BUDGET, { variables: { id: budgetId } })

  if (data?.budget) {
    const header = () => {
      return (
        <View style={{ alignItems: 'center' }}>
          <Text style={{ color: colors.text, fontWeight: 'bold', fontSize: 18 }}>{formatCurrency(data.budget.balance)}</Text>
          <Text style={{ color: colors.secondary, fontSize: 12 }}>{data.budget.name}</Text>
        </View>
      )
    }

    navigation.setOptions({ headerTitle: header })
  } else {
    navigation.setOptions({ headerTitle: '' })
    return <ActivityIndicator color={colors.text} style={styles.activityIndicator} />
  }

  const sections = [
    {
      title: 'Templates',
      data: data.budget.allocationTemplateLines,
      renderItem: ({ item }: {item: AllocationTemplateLine}) => <Text style={{ color: 'white' }}>{item.allocationTemplate.name}</Text>
    },
    { 
      title: 'Recent Transactions', 
      data: data.budget.recentAllocations, 
      renderItem: ({ item }: {item: Allocation}) => <Text style={{ color: 'white' }}>{item.transaction.name}</Text> 
    },
  ]

  return (
    <SectionList
      contentContainerStyle={{
        paddingBottom: 40
      }}
      sections={sections}
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