import React, { useLayoutEffect } from 'react'
import { RefreshControl, } from 'react-native'
import { useNavigation } from '@react-navigation/native'
import { FlatList } from 'react-native-gesture-handler'
import { useQuery } from '@apollo/client'
import TemplateRow, { TemplateRowItem } from '../components/TemplateRow'
import Decimal from 'decimal.js-light'
import useAppStyles from 'src/utils/useAppStyles'
import HeaderButton from 'src/components/HeaderButton'
import { ListAllocationTemplates } from 'src/graphql/ListAllocationTemplates'
import { LIST_TEMPLATES } from 'src/queries'

const Templates = () => {
  const navigation = useNavigation<NavigationProp>()
  const { styles, colors } = useAppStyles()

  const navigateToCreateTemplate = () => navigation.navigate('Create Template')
  const headerRight = () => <HeaderButton title="Add" onPress={navigateToCreateTemplate} />
  useLayoutEffect(() => navigation.setOptions({ headerRight: headerRight }))

  const { data, loading, refetch } = useQuery<ListAllocationTemplates>(LIST_TEMPLATES)

  const templates: TemplateRowItem[] =
    [...data?.allocationTemplates ?? []]
      .sort((a, b) => {
        const aAllocated = a.lines.reduce((acc, line) => acc.add(line.amount), new Decimal('0'))
        const bAllocated = b.lines.reduce((acc, line) => acc.add(line.amount), new Decimal('0'))

        return bAllocated.comparedTo(aAllocated)
      })
      .map(template => {
        const allocated = template.lines.reduce((acc, line) => acc.add(line.amount), new Decimal('0'))
        
        return {
          key: template.id,
          templateId: template.id,
          name: template.name,
          amount: allocated,
          hideDelete: true,
          onPress: () => navigation.navigate('Template', { templateId: template.id })
        }
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

export default Templates