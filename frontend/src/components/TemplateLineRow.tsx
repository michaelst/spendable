import React from 'react'
import {
  Text,
  TouchableHighlight,
  View
} from 'react-native'
import { useNavigation } from '@react-navigation/native'
import formatCurrency from 'src/utils/formatCurrency'
import Swipeable from 'react-native-gesture-handler/Swipeable'
import { RectButton } from 'react-native-gesture-handler'
import { useMutation } from '@apollo/client'
import useAppStyles from 'src/hooks/useAppStyles'
import { FontAwesomeIcon } from '@fortawesome/react-native-fontawesome'
import { faChevronRight } from '@fortawesome/free-solid-svg-icons'
import { GetBudgetAllocationTemplate_budgetAllocationTemplate_budgetAllocationTemplateLines } from 'src/graphql/GetBudgetAllocationTemplate'
import { DELETE_BUDGET_ALLOCATION_TEMPLATE_LINE } from 'src/queries'
import { DeleteBudgetAllocationTemplateLine } from 'src/graphql/DeleteBudgetAllocationTemplateLine'

type Props = {
  line: GetBudgetAllocationTemplate_budgetAllocationTemplate_budgetAllocationTemplateLines,
}

const TemplateLineRow = ({ line }: Props) => {
  const navigation = useNavigation<NavigationProp>()
  const { styles, fontSize, colors } = useAppStyles()

  const navigateToEdit = () => navigation.navigate('Edit Template Line', { lineId: line.id })

  const [deleteAllocationTemplateLine] = useMutation(DELETE_BUDGET_ALLOCATION_TEMPLATE_LINE, {
    variables: { id: line.id },
    update(cache, { data }) {
      const { deleteBudgetAllocationTemplateLine }: DeleteBudgetAllocationTemplateLine = data
      cache.evict({ id: 'BudgetAllocationTemplateLine:' + deleteBudgetAllocationTemplateLine?.result?.id })
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
            <FontAwesomeIcon icon={faChevronRight} size={fontSize} color={colors.secondary} />
          </View>
        </View>
      </Swipeable>
    </TouchableHighlight>
  )
}

export default TemplateLineRow
