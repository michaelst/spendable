import React from 'react'
import {
  StyleSheet,
  Text,
  TouchableHighlight,
  View
} from 'react-native'
import { useNavigation } from '@react-navigation/native'
import { useTheme } from '@react-navigation/native'
import { Ionicons } from '@expo/vector-icons'
import { ListAllocationTemplates, ListAllocationTemplates_allocationTemplates } from '../graphql/ListAllocationTemplates'
import Decimal from 'decimal.js-light'
import formatCurrency from 'helpers/formatCurrency'
import { RectButton } from 'react-native-gesture-handler'
import Swipeable from 'react-native-gesture-handler/Swipeable'
import { DELETE_TEMPLATE, LIST_TEMPLATES } from '../queries'
import { useMutation } from '@apollo/client'
import AppStyles from 'constants/AppStyles'

type Props = {
  template: ListAllocationTemplates_allocationTemplates,
}

export default function TemplateRow({ template }: Props) {
  const navigation = useNavigation()
  const { colors }: any = useTheme()
  const styles = AppStyles()

  const navigateToTemplate = () => navigation.navigate('Template', { templateId: template.id })

  const [deleteAllocationTemplate] = useMutation(DELETE_TEMPLATE, {
    variables: { id: template.id },
    update(cache, { data: { deleteAllocationTemplate } }) {
      const data = cache.readQuery<ListAllocationTemplates | null>({ query: LIST_TEMPLATES })

      cache.writeQuery({
        query: LIST_TEMPLATES,
        data: { allocationTemplates: data?.allocationTemplates.filter(template => template.id !== deleteAllocationTemplate.id) }
      })
    }
  })

  const allocated = template.lines.reduce((acc, line) => acc.add(line.amount), new Decimal('0'))

  const renderRightActions = () => {
    return (
      <RectButton style={styles.deleteButton}>
        <Text style={styles.deleteButtonText}>Delete</Text>
      </RectButton>
    )
  }

  return (
    <TouchableHighlight onPress={navigateToTemplate}>
      <Swipeable
        renderRightActions={renderRightActions}
        onSwipeableOpen={deleteAllocationTemplate}
      >
        <View
          style={{
            flexDirection: 'row',
            padding: 18,
            alignItems: 'center',
            backgroundColor: colors.card,
            borderBottomColor: colors.border,
            borderBottomWidth: StyleSheet.hairlineWidth
          }}
        >
          <View style={{ flex: 1 }}>
            <Text style={{ color: colors.text, fontSize: 18 }}>
              {template.name}
            </Text>
          </View>

          <View style={{ flexDirection: "row" }}>
            <Text style={{ color: colors.secondary, fontSize: 18, paddingRight: 8 }} >
              {formatCurrency(allocated)}
            </Text>
            <Ionicons name='ios-arrow-forward' size={18} color={colors.secondary} />
          </View>
        </View>
      </Swipeable>
    </TouchableHighlight>
  )
}
