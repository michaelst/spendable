import React, { useLayoutEffect } from 'react'
import {
  ActivityIndicator,
  SectionList,
  Text,
  View,
} from 'react-native'
import { RouteProp, useRoute, useNavigation } from '@react-navigation/native'
import { useQuery } from '@apollo/client'
import { GET_TEMPLATE } from 'src/screens/settings/queries'
import {
  GetAllocationTemplate,
  GetAllocationTemplate_allocationTemplate_lines as AllocationTemplateLine
} from 'src/screens/settings/graphql/GetAllocationTemplate'
import { TouchableHighlight } from 'react-native-gesture-handler'
import TemplateLineRow from './settings/screens/TemplateLineRow'
import useAppStyles from 'src/utils/useAppStyles'
import HeaderButton from 'src/components/HeaderButton'

const Template = () => {
  const { styles, colors } = useAppStyles()

  const navigation = useNavigation<NavigationProp>()
  const { params: { templateId } } = useRoute<RouteProp<RootStackParamList, 'Template'>>()

  const navigateToCreate = () => navigation.navigate('Create Template Line', { templateId: templateId })
  const navigateToEdit = () => navigation.navigate('Edit Template', { templateId: templateId })
  const headerRight = () => <HeaderButton title="Edit" onPress={navigateToEdit} />

  const { data } = useQuery<GetAllocationTemplate>(GET_TEMPLATE, { variables: { id: templateId } })

  if (data) {
    const headerTitle = () => {
      return (
        <View style={{ alignItems: 'center' }}>
          <Text style={styles.headerTitleText}>{data.allocationTemplate.name}</Text>
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
      contentContainerStyle={styles.sectionListContentContainerStyle}
      sections={sections}
      renderSectionHeader={({ section: { title } }) => <Text style={styles.sectionHeaderText}>{title}</Text>}
      renderSectionFooter={() => (
        <TouchableHighlight onPress={navigateToCreate}>
          <Text style={[styles.sectionFooterText, { color: colors.primary }]}>Add Expense/Goal</Text>
        </TouchableHighlight>
      )}
      stickySectionHeadersEnabled={false}
    />
  )
}

export default Template