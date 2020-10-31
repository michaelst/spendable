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
import AppStyles from 'constants/AppStyles'

type Props = {
  templateLine: GetBudget_budget_allocationTemplateLines,
}

export default function TemplateRow({ templateLine }: Props) {
  const navigation = useNavigation()
  const { colors }: any = useTheme()
  const { styles, fontSize} = AppStyles()

  const navigateToTemplate = () => navigation.navigate('Template', { templateId: templateLine.allocationTemplate.id })

  return (
    <TouchableHighlight onPress={navigateToTemplate}>
      <View style={styles.row}>
        <View style={{ flex: 1 }}>
          <Text style={styles.text}>
            {templateLine.allocationTemplate.name}
          </Text>
        </View>

        <View style={{ flexDirection: "row" }}>
          <Text style={styles.rightText} >
            {formatCurrency(templateLine.amount)}
          </Text>
          <Ionicons name='ios-arrow-forward' size={18} color={colors.secondary} />
        </View>
      </View>
    </TouchableHighlight>
  )
}
