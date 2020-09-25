import React from 'react'
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

  const headerRight = () => {
    return (
      <TouchableWithoutFeedback onPress={() => console.log('test')}>
        <Text style={{ color: colors.primary, fontSize: 18, paddingRight: 18 }}>Add</Text>
      </TouchableWithoutFeedback>
    )
  }

  navigation.setOptions({ headerRight: headerRight })

  if (loading && !data) return <ActivityIndicator color={colors.text} style={styles.activityIndicator} />

  return (
    <FlatList
      contentContainerStyle={{ paddingTop: 36, paddingBottom: 36 }}
      data={data?.allocationTemplates ?? []}
      renderItem={({ item }) => <TemplateRow template={item} />}
      refreshControl={<RefreshControl refreshing={loading} onRefresh={refetch} />}
    />
  )
}