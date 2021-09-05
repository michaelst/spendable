import React from 'react'
import {
  Text,
  TouchableHighlight,
  View
} from 'react-native'
import { useNavigation } from '@react-navigation/native'
import { Ionicons } from '@expo/vector-icons'
import formatCurrency from 'src/utils/formatCurrency'
import useAppStyles from 'src/utils/useAppStyles'
import { GetBudget_budget_allocationTemplateLines } from 'src/graphql/GetBudget'

type Props = {
  templateLine: GetBudget_budget_allocationTemplateLines,
}

const TemplateRow = ({ templateLine }: Props) => {
  const navigation = useNavigation<NavigationProp>()
  const { styles, fontSize, colors } = useAppStyles()

  const navigateToTemplate = () => navigation.navigate('Template', { templateId: templateLine.allocationTemplate.id })

  return (
    <TouchableHighlight onPress={navigateToTemplate}>
      <View style={styles.row}>
        <View style={styles.flex}>
          <Text style={styles.text}>
            {templateLine.allocationTemplate.name}
          </Text>
        </View>

        <View style={{ flexDirection: "row" }}>
          <Text style={styles.rightText} >
            {formatCurrency(templateLine.amount)}
          </Text>
          <Ionicons name='chevron-forward-outline' size={fontSize} color={colors.secondary} />
        </View>
      </View>
    </TouchableHighlight>
  )
}

export default TemplateRow