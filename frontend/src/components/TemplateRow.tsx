import React from 'react'
import {
  Text,
  TouchableHighlight,
  View
} from 'react-native'
import { Ionicons } from '@expo/vector-icons'
import Decimal from 'decimal.js-light'
import formatCurrency from 'src/utils/formatCurrency'
import { RectButton } from 'react-native-gesture-handler'
import Swipeable from 'react-native-gesture-handler/Swipeable'
import { useMutation } from '@apollo/client'
import useAppStyles from 'src/utils/useAppStyles'
import { DELETE_TEMPLATE } from 'src/queries'

export type TemplateRowItem = {
  key: string
  templateId: string
  name: string
  amount: Decimal
  hideDelete?: boolean
  onPress: () => void
}

type TemplateRowProps = {
  item: TemplateRowItem
}

const TemplateRow = ({ item }: TemplateRowProps) => {
  const { styles } = useAppStyles()

  const [deleteAllocationTemplate] = useMutation(DELETE_TEMPLATE, {
    variables: { id: item.templateId },
    update(cache, { data: { deleteAllocationTemplate } }) {
      cache.evict({ id: 'AllocationTemplate:' + deleteAllocationTemplate.id })
      cache.gc()
    }
  })

  if (item.hideDelete) return <Row item={item} />

  const renderRightActions = () => {
    return (
      <RectButton style={styles.deleteButton}>
        <Text style={styles.deleteButtonText}>Delete</Text>
      </RectButton>
    )
  }

  return (
    <Swipeable
      renderRightActions={renderRightActions}
      onSwipeableOpen={deleteAllocationTemplate}
    >
      <Row item={item} />
    </Swipeable>
  )
}

const Row = ({ item: { name, amount, onPress } }: TemplateRowProps) => {
  const { styles, fontSize, colors } = useAppStyles()

  return (
    <TouchableHighlight onPress={onPress}>
      <View style={styles.row}>
        <View style={styles.flex}>
          <Text style={styles.text}>
            {name}
          </Text>
        </View>

        <View style={{ flexDirection: "row" }}>
          <Text style={styles.rightText} >
            {formatCurrency(amount)}
          </Text>
          <Ionicons name='chevron-forward-outline' size={fontSize} color={colors.secondary} />
        </View>
      </View>
    </TouchableHighlight >
  )
}

export default TemplateRow
