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
import formatCurrency from 'helpers/formatCurrency'
import { GetBudget_budget_allocationTemplateLines } from '../graphql/GetBudget'

type Props = {
  templateLine: GetBudget_budget_allocationTemplateLines,
}

export default function TemplateRow({ templateLine }: Props) {
  const navigation = useNavigation()
  const { colors }: any = useTheme()

  const navigateToTemplate = () => navigation.navigate('Template', { templateId: templateLine.allocationTemplate.id })

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
            {templateLine.allocationTemplate.name}
          </Text>
        </View>

        <View style={{ flexDirection: "row" }}>
          <Text style={{ color: colors.secondary, fontSize: 18, paddingRight: 8 }} >
            {formatCurrency(templateLine.amount)}
          </Text>
          <Ionicons name='ios-arrow-forward' size={18} color={colors.secondary} />
        </View>
      </View>
    </TouchableHighlight>
  )
}
