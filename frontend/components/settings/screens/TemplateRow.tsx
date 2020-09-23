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
import { ListAllocationTemplates_allocationTemplates } from '../graphql/ListAllocationTemplates'
import Decimal from 'decimal.js-light'
import formatCurrency from 'helpers/formatCurrency'

type Props = {
  template: ListAllocationTemplates_allocationTemplates,
}

export default function TemplateRow({ template }: Props) {
  const navigation = useNavigation()
  const { colors }: any = useTheme()

  const navigateToTemplate = () => navigation.navigate('Template', { templateId: template.id })

  const allocated = template.lines.reduce((acc, line) => acc.add(line.amount), new Decimal('0'))

  return (
    <TouchableHighlight onPress={navigateToTemplate}>
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
    </TouchableHighlight>
  )
}
