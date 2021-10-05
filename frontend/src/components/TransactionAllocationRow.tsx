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
import useAppStyles from 'src/utils/useAppStyles'
import { faChevronRight } from '@fortawesome/free-solid-svg-icons'
import { FontAwesomeIcon } from '@fortawesome/react-native-fontawesome'
import { GetTransaction_transaction_budgetAllocations } from 'src/graphql/GetTransaction'
import { DELETE_BUDGET_ALLOCATION } from 'src/queries'
import { DeleteBudgetAllocation } from 'src/graphql/DeleteBudgetAllocation'

type Props = {
  allocation: GetTransaction_transaction_budgetAllocations
}

const TransactionAllocationRow = ({ allocation }: Props) => {
  const navigation = useNavigation<NavigationProp>()
  const { styles, fontSize, colors } = useAppStyles()

  const navigateToEdit = () => navigation.navigate('Edit Allocation', { allocationId: allocation.id })

  const [deleteAllocation] = useMutation(DELETE_BUDGET_ALLOCATION, {
    variables: { id: allocation.id },
    update(cache, { data }) {
      const { deleteBudgetAllocation }: DeleteBudgetAllocation = data
      cache.evict({ id: 'BudgetAllocation:' + deleteBudgetAllocation?.result?.id })
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

  if (allocation.id === 'spendable') {
    return (
      <View style={styles.row}>
        <View style={{ flex: 1 }}>
          <Text style={styles.text}>
            {allocation.budget.name}
          </Text>
        </View>

        <View style={{ flexDirection: "row" }}>
          <Text style={styles.rightText} >
            {formatCurrency(allocation.amount)}
          </Text>
        </View>
      </View>
    )
  }

  return (
    <TouchableHighlight onPress={navigateToEdit}>
      <Swipeable
        renderRightActions={renderRightActions}
        onSwipeableOpen={deleteAllocation}
      >
        <View style={styles.row}>
          <View style={{ flex: 1 }}>
            <Text style={styles.text}>
              {allocation.budget.name}
            </Text>
          </View>

          <View style={{ flexDirection: "row" }}>
            <Text style={styles.rightText} >
              {formatCurrency(allocation.amount)}
            </Text>
            <FontAwesomeIcon icon={faChevronRight} size={fontSize} color={colors.secondary} />
          </View>
        </View>
      </Swipeable>
    </TouchableHighlight>
  )
}

export default TransactionAllocationRow
