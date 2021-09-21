import React, { useLayoutEffect } from 'react'
import {
  Text,
  View,
} from 'react-native'
import { RouteProp, useRoute, useNavigation } from '@react-navigation/native'
import { useQuery } from '@apollo/client'
import { FlatList, TouchableHighlight } from 'react-native-gesture-handler'
import TemplateLineRow from '../components/TemplateLineRow'
import useAppStyles from 'src/utils/useAppStyles'
import HeaderButton from 'src/components/HeaderButton'
import { GetAllocationTemplate } from 'src/graphql/GetAllocationTemplate'
import { GET_TEMPLATE } from 'src/queries'
import { AllocationTemplateLine } from 'src/graphql/AllocationTemplateLine'

const Template = () => {
  const { styles, colors } = useAppStyles()

  const navigation = useNavigation<NavigationProp>()
  const { params: { templateId } } = useRoute<RouteProp<RootStackParamList, 'Template'>>()

  const navigateToCreate = () => navigation.navigate('Create Template Line', { templateId: templateId })
  const navigateToEdit = () => navigation.navigate('Edit Template', { templateId: templateId })
  const headerRight = () => <HeaderButton title="Edit" onPress={navigateToEdit} />

  const { data } = useQuery<GetAllocationTemplate>(GET_TEMPLATE, { variables: { id: templateId } })

  useLayoutEffect(() => navigation.setOptions({ headerTitle: data?.allocationTemplate.name, headerRight: headerRight }))

  if (!data) return null
  
  const lines = [...data.allocationTemplate.lines].sort((a, b) => b.amount.comparedTo(a.amount))

  return (
    <FlatList
      data={lines}
      renderItem={({ item }: { item: AllocationTemplateLine }) => <TemplateLineRow line={item} />}
      ListFooterComponent={() => (
        <TouchableHighlight onPress={navigateToCreate}>
          <View style={styles.footer}>
            <Text style={{ color: colors.primary }}>Add Expense/Goal</Text>
          </View>
        </TouchableHighlight>
      )}
      contentInsetAdjustmentBehavior="automatic"
    />
  )
}

export default Template