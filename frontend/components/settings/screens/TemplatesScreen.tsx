import React, { useLayoutEffect } from 'react'
import {
  StyleSheet,
  ActivityIndicator,
  RefreshControl,
  Text
} from 'react-native'
import { useTheme, useNavigation } from '@react-navigation/native'
import { FlatList, TouchableWithoutFeedback } from 'react-native-gesture-handler'
import { LIST_TEMPLATES } from '../queries'
import { useQuery } from '@apollo/client'
import TemplateRow from './TemplateRow'
import { ListAllocationTemplates } from '../graphql/ListAllocationTemplates'
import Decimal from 'decimal.js-light'

export default function TemplatesScreen() {
  const navigation = useNavigation()
  const { colors }: any = useTheme()

  const styles = StyleSheet.create({
    activityIndicator: {
      flex: 1,
      alignItems: 'center',
      justifyContent: 'center',
    }
  })

  const { data, loading, refetch } = useQuery<ListAllocationTemplates>(LIST_TEMPLATES)
  const navigateToCreateTemplate = () => navigation.navigate('Create Template')

  const headerRight = () => {
    return (
      <TouchableWithoutFeedback onPress={navigateToCreateTemplate}>
        <Text style={{ color: colors.primary, fontSize: 18, paddingRight: 18 }}>Add</Text>
      </TouchableWithoutFeedback>
    )
  }

  useLayoutEffect(() => navigation.setOptions({ headerRight: headerRight }))

  if (loading && !data) return <ActivityIndicator color={colors.text} style={styles.activityIndicator} />

  const templates = [...data?.allocationTemplates ?? []].sort((a, b) => {
    const aAllocated = a.lines.reduce((acc, line) => acc.add(line.amount), new Decimal('0'))
    const bAllocated = b.lines.reduce((acc, line) => acc.add(line.amount), new Decimal('0'))
    
    return bAllocated.comparedTo(aAllocated)
  })

  return (
    <FlatList
      contentContainerStyle={{ paddingTop: 36, paddingBottom: 36 }}
      data={templates}
      renderItem={({ item }) => <TemplateRow template={item} />}
      refreshControl={<RefreshControl refreshing={loading} onRefresh={refetch} />}
    />
  )
}