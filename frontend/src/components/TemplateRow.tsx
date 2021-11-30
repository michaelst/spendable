import React from 'react'
import {
  Text,
  TouchableHighlight,
  View
} from 'react-native'
import Decimal from 'decimal.js-light'
import formatCurrency from 'src/utils/formatCurrency'
import { useMutation } from '@apollo/client'
import useAppStyles from 'src/hooks/useAppStyles'
import { FontAwesomeIcon } from '@fortawesome/react-native-fontawesome'
import { faChevronRight } from '@fortawesome/free-solid-svg-icons'
import { DeleteBudgetAllocationTemplate } from 'src/graphql/DeleteBudgetAllocationTemplate'
import { DELETE_BUDGET_ALLOCATION_TEMPLATE } from 'src/queries'
import SwipeableRow from './SwipeableRow'

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
  const [deleteAllocationTemplate] = useMutation(DELETE_BUDGET_ALLOCATION_TEMPLATE, {
    variables: { id: item.templateId },
    update(cache, { data }) {
      const { deleteBudgetAllocationTemplate }: DeleteBudgetAllocationTemplate = data
      cache.evict({ id: 'BudgetAllocationTemplate:' + deleteBudgetAllocationTemplate?.result?.id })
      cache.gc()
    }
  })

  if (item.hideDelete) return <Row item={item} />

  return (
    <SwipeableRow onPress={deleteAllocationTemplate} >
      <Row item={item} />
    </SwipeableRow>
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
          <FontAwesomeIcon icon={faChevronRight} size={fontSize} color={colors.secondary} />
        </View>
      </View>
    </TouchableHighlight >
  )
}

export default TemplateRow
