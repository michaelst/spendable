import React, { useLayoutEffect } from 'react'
import {
  ActivityIndicator,
  Text,
  View,
} from 'react-native'
import { RouteProp, useRoute, useNavigation } from '@react-navigation/native'
import { useQuery } from '@apollo/client'
import { FlatList, TouchableHighlight } from 'react-native-gesture-handler'
import TemplateLineRow from '../components/TemplateLineRow'
import useAppStyles from 'src/hooks/useAppStyles'
import HeaderButton from 'src/components/HeaderButton'
import { GET_BUDGET_ALLOCATION_TEMPLATE } from 'src/queries'
import { GetBudgetAllocationTemplate } from 'src/graphql/GetBudgetAllocationTemplate'
import { BudgetAllocationTemplateLine } from 'src/graphql/BudgetAllocationTemplateLine'

const BudgetAllocationTemplate = () => {
  const { styles, colors } = useAppStyles()

  const navigation = useNavigation<NavigationProp>()
  const { params: { templateId } } = useRoute<RouteProp<RootStackParamList, 'Template'>>()

  const navigateToCreate = () => navigation.navigate('Create Template Line', { templateId: templateId })
  const navigateToEdit = () => navigation.navigate('Edit Template', { templateId: templateId })
  const headerRight = () => <HeaderButton title="Edit" onPress={navigateToEdit} />

  const { data } = useQuery<GetBudgetAllocationTemplate>(GET_BUDGET_ALLOCATION_TEMPLATE, { variables: { id: templateId } })

  useLayoutEffect(() => navigation.setOptions({ headerTitle: data?.budgetAllocationTemplate.name, headerRight: headerRight }))

  if (!data) return <ActivityIndicator color={colors.text} style={styles.activityIndicator} />
  
  const lines = [...data.budgetAllocationTemplate.budgetAllocationTemplateLines].sort((a, b) => b.amount.comparedTo(a.amount))

  return (
    <FlatList
      data={lines}
      renderItem={({ item }: { item: BudgetAllocationTemplateLine }) => <TemplateLineRow line={item} />}
      ListFooterComponent={() => (
        <TouchableHighlight onPress={navigateToCreate}>
          <View style={styles.footer}>
            <Text style={{ color: colors.primary }}>Add Expense</Text>
          </View>
        </TouchableHighlight>
      )}
      contentInsetAdjustmentBehavior="automatic"
    />
  )
}

export default BudgetAllocationTemplate