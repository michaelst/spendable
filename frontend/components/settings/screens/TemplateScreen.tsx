import React from 'react'
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
import formatCurrency from 'helpers/formatCurrency'
import { 
  GetAllocationTemplate,
  GetAllocationTemplate_allocationTemplate_lines as AllocationTemplateLine
} from 'components/settings/graphql/GetAllocationTemplate'
import { TouchableWithoutFeedback } from 'react-native-gesture-handler'

export default function TemplateScreen() {
  const { colors }: any = useTheme()

  const navigation = useNavigation()
  const route = useRoute<RouteProp<RootStackParamList, 'Template'>>()
  const { templateId } = route.params

  const navigateToEdit = () => navigation.navigate('Edit Template', { templateId: templateId })
  
  const { data, error } = useQuery<GetAllocationTemplate>(GET_TEMPLATE, { variables: { id: templateId } })

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

    navigation.setOptions({ headerTitle: headerTitle, headerRight: headerRight })
  } else {
    navigation.setOptions({ headerTitle: '', headerRight: headerRight })
    return <ActivityIndicator color={colors.text} style={styles.activityIndicator} />
  }

  const sections = [
    {
      title: 'Expenses/Goals',
      data: data.allocationTemplate.lines,
      renderItem: ({ item }: { item: AllocationTemplateLine }) => <Text>{item.budget.name}</Text>
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