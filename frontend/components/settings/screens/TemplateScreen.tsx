import React, { useLayoutEffect } from 'react'
import {
  ActivityIndicator,
  SectionList,
  Text,
  View,
} from 'react-native'
import { useTheme, RouteProp, useRoute, useNavigation } from '@react-navigation/native'
import { useQuery } from '@apollo/client'
import { RootStackParamList } from 'components/settings/Settings'
import { GET_TEMPLATE } from 'components/settings/queries'
import { 
  GetAllocationTemplate,
  GetAllocationTemplate_allocationTemplate_lines as AllocationTemplateLine
} from 'components/settings/graphql/GetAllocationTemplate'
import { TouchableHighlight } from 'react-native-gesture-handler'
import TemplateLineRow from './TemplateLineRow'
import AppStyles from 'constants/AppStyles'
import HeaderButton from 'components/shared/components/HeaderButton'

export default function TemplateScreen() {
  const { colors }: any = useTheme()
  const styles = AppStyles()

  const navigation = useNavigation()
  const route = useRoute<RouteProp<RootStackParamList, 'Template'>>()
  const { templateId } = route.params

  const navigateToCreate = () => navigation.navigate('Create Template Line', { templateId: templateId })
  const navigateToEdit = () => navigation.navigate('Edit Template', { templateId: templateId })
  const headerRight = () => <HeaderButton text="Edit" onPress={navigateToEdit} />
  
  const { data } = useQuery<GetAllocationTemplate>(GET_TEMPLATE, { variables: { id: templateId } })

  if (data?.allocationTemplate) {
    const headerTitle = () => {
      return (
        <View style={{ alignItems: 'center' }}>
          <Text style={{ color: colors.text, fontWeight: 'bold', fontSize: 18 }}>{data.allocationTemplate.name}</Text>
        </View>
      )
    }

    useLayoutEffect(() => navigation.setOptions({ headerTitle: headerTitle, headerRight: headerRight }))
  } else {
    useLayoutEffect(() => navigation.setOptions({ headerTitle: '', headerRight: headerRight }))
    return <ActivityIndicator color={colors.text} style={styles.activityIndicator} />
  }

  const lines = [...data.allocationTemplate.lines].sort((a, b) => b.amount.comparedTo(a.amount))

  const sections = [
    {
      title: 'Expenses/Goals',
      data: lines,
      renderItem: ({ item }: { item: AllocationTemplateLine }) => <TemplateLineRow line={item} templateId={templateId} />
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
            paddingBottom: 10
          }}
        >
          {title}
        </Text>
      )}
      renderSectionFooter={() => (
        <TouchableHighlight onPress={navigateToCreate}>
          <Text
            style={{
              backgroundColor: colors.background,
              color: colors.primary,
              padding: 18,
              paddingTop: 10
            }}
          >
            Add Expense/Goal
          </Text>
        </TouchableHighlight>
      )}
      stickySectionHeadersEnabled={false}
    />
  )
}