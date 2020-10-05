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
import { RootStackParamList } from 'components/settings/Settings'
import { GET_TEMPLATE } from 'components/settings/queries'
import { 
  GetAllocationTemplate,
  GetAllocationTemplate_allocationTemplate_lines as AllocationTemplateLine
} from 'components/settings/graphql/GetAllocationTemplate'
import { TouchableHighlight, TouchableWithoutFeedback } from 'react-native-gesture-handler'
import TemplateLineRow from './TemplateLineRow'

export default function TemplateScreen() {
  const { colors }: any = useTheme()

  const navigation = useNavigation()
  const route = useRoute<RouteProp<RootStackParamList, 'Template'>>()
  const { templateId } = route.params

  const navigateToEdit = () => navigation.navigate('Edit Template', { templateId: templateId })
  const navigateToCreate = () => navigation.navigate('Create Template Line', { templateId: templateId })
  
  const { data } = useQuery<GetAllocationTemplate>(GET_TEMPLATE, { variables: { id: templateId } })

  const headerRight = () => {
    return (
      <TouchableWithoutFeedback onPress={navigateToEdit}>
        <Text style={{ color: colors.primary, fontSize: 18, paddingRight: 18 }}>Edit</Text>
      </TouchableWithoutFeedback>
    )
  }

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
      renderItem: ({ item }: { item: AllocationTemplateLine }) => <TemplateLineRow line={item} />
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

const styles = StyleSheet.create({
  activityIndicator: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  }
})