import React from 'react'
import {
  Text,
  TouchableHighlight,
  View
} from 'react-native'
import { useNavigation } from '@react-navigation/native'
import { useTheme } from '@react-navigation/native'
import { Ionicons } from '@expo/vector-icons'
import formatCurrency from 'helpers/formatCurrency'
import { GetAllocationTemplate_allocationTemplate_lines } from '../graphql/GetAllocationTemplate'
import Swipeable from 'react-native-gesture-handler/Swipeable'
import { RectButton } from 'react-native-gesture-handler'
import { DELETE_TEMPLATE_LINE } from '../queries'
import { useMutation } from '@apollo/client'
import AppStyles from 'constants/AppStyles'

type Props = {
  line: GetAllocationTemplate_allocationTemplate_lines,
}

export default function TemplateLineRow({ line }: Props) {
  const navigation = useNavigation()
  const { colors }: any = useTheme()
  const { styles, fontSize } = AppStyles()

  const navigateToEdit = () => navigation.navigate('Edit Template Line', { lineId: line.id })

  const [deleteAllocationTemplateLine] = useMutation(DELETE_TEMPLATE_LINE, {
    variables: { id: line.id },
    update(cache, { data: { deleteAllocationTemplateLine } }) {
      cache.evict({ id: 'AllocationTemplateLine:' + deleteAllocationTemplateLine.id })
      cache.gc()
    }
  })

  const renderRightActions = () => {
    return (
      <RectButton style={styles.deleteButton}>
        <Text style={styles.deleteButtonText}>Delete</Text>
      </RectButton>
    )
  }

  return (
    <TouchableHighlight onPress={navigateToEdit}>
      <Swipeable
        renderRightActions={renderRightActions}
        onSwipeableOpen={deleteAllocationTemplateLine}
      >
        <View style={styles.row}>
          <View style={{ flex: 1 }}>
            <Text style={styles.text}>
              {line.budget.name}
            </Text>
          </View>

          <View style={{ flexDirection: "row" }}>
            <Text style={styles.rightText} >
              {formatCurrency(line.amount)}
            </Text>
            <Ionicons name='chevron-forward-outline' size={fontSize} color={colors.secondary} />
          </View>
        </View>
      </Swipeable>
    </TouchableHighlight>
  )
}
