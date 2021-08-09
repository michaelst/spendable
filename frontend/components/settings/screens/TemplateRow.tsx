import React from 'react'
import {
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
import { RectButton } from 'react-native-gesture-handler'
import Swipeable from 'react-native-gesture-handler/Swipeable'
import { DELETE_TEMPLATE } from '../queries'
import { useMutation } from '@apollo/client'
import AppStyles from 'constants/AppStyles'

type Props = {
  template: ListAllocationTemplates_allocationTemplates,
}

export default function TemplateRow({ template }: Props) {
  const navigation = useNavigation()
  const { colors }: any = useTheme()
  const { styles, fontSize } = AppStyles()

  const navigateToTemplate = () => navigation.navigate('Template', { templateId: template.id })

  const [deleteAllocationTemplate] = useMutation(DELETE_TEMPLATE, {
    variables: { id: template.id },
    update(cache, { data: { deleteAllocationTemplate } }) {
      cache.evict({ id: 'AllocationTemplate:' + deleteAllocationTemplate.id })
      cache.gc()
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
        <View style={styles.row}>
          <View style={{ flex: 1 }}>
            <Text style={styles.text}>
              {template.name}
            </Text>
          </View>

          <View style={{ flexDirection: "row" }}>
            <Text style={styles.rightText} >
              {formatCurrency(allocated)}
            </Text>
            <Ionicons name='chevron-forward-outline' size={fontSize} color={colors.secondary} />
          </View>
        </View>
      </Swipeable>
    </TouchableHighlight>
  )
}
