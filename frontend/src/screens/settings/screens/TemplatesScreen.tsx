import React, { useLayoutEffect } from 'react'
import { ActivityIndicator, RefreshControl, } from 'react-native'
import { useTheme, useNavigation } from '@react-navigation/native'
import { FlatList } from 'react-native-gesture-handler'
import { LIST_TEMPLATES } from '../queries'
import { useQuery } from '@apollo/client'
import TemplateRow from './TemplateRow'
import { ListAllocationTemplates } from '../graphql/ListAllocationTemplates'
import Decimal from 'decimal.js-light'
import AppStyles from 'src/utils/useAppStyles'
import HeaderButton from 'src/components/HeaderButton'

export default function TemplatesScreen() {
  const navigation = useNavigation()
  const { colors }: any = useTheme()
  const { styles } = AppStyles()

  const navigateToCreateTemplate = () => navigation.navigate('Create Template')
  const headerRight = () => <HeaderButton title="Add" onPress={navigateToCreateTemplate} />

  const { data, loading, refetch } = useQuery<ListAllocationTemplates>(LIST_TEMPLATES)

  useLayoutEffect(() => navigation.setOptions({ headerRight: headerRight }))

  if (loading && !data) return <ActivityIndicator color={colors.text} style={styles.activityIndicator} />

  const templates = [...data?.allocationTemplates ?? []].sort((a, b) => {
    const aAllocated = a.lines.reduce((acc, line) => acc.add(line.amount), new Decimal('0'))
    const bAllocated = b.lines.reduce((acc, line) => acc.add(line.amount), new Decimal('0'))

    return bAllocated.comparedTo(aAllocated)
  })

  return (
    <FlatList
      contentContainerStyle={styles.flatlistContentContainerStyle}
      data={templates}
      renderItem={({ item }) => <TemplateRow template={item} />}
      refreshControl={<RefreshControl refreshing={loading} onRefresh={refetch} />}
    />
  )
}