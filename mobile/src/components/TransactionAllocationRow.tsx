import React, { useContext } from 'react'
import {
  Text,
  TouchableHighlight,
  View
} from 'react-native'
import { RouteProp, useNavigation, useRoute } from '@react-navigation/native'
import formatCurrency from 'src/utils/formatCurrency'
import { useMutation } from '@apollo/client'
import useAppStyles from 'src/hooks/useAppStyles'
import { faChevronRight } from '@fortawesome/free-solid-svg-icons'
import { FontAwesomeIcon } from '@fortawesome/react-native-fontawesome'
import { GetTransaction_transaction_budgetAllocations } from 'src/graphql/GetTransaction'
import { DELETE_BUDGET_ALLOCATION, GET_TRANSACTION, MAIN_QUERY } from 'src/queries'
import { DeleteBudgetAllocation } from 'src/graphql/DeleteBudgetAllocation'
import SwipeableRow from './SwipeableRow'
import SettingsContext from 'src/context/Settings'

type Props = {
  allocation: GetTransaction_transaction_budgetAllocations
}

const TransactionAllocationRow = ({ allocation }: Props) => {
  const { activeMonth } = useContext(SettingsContext)
  const { styles } = useAppStyles()
  const { params: { transactionId } } = useRoute<RouteProp<RootStackParamList, 'Spend From'>>()

  const [deleteAllocation] = useMutation(DELETE_BUDGET_ALLOCATION, {
    variables: { id: allocation.id },
    update(cache, { data }) {
      const { deleteBudgetAllocation }: DeleteBudgetAllocation = data
      cache.evict({ id: 'BudgetAllocation:' + deleteBudgetAllocation?.result?.id })
      cache.gc()
    },
    refetchQueries: [
      { query: MAIN_QUERY, variables: { month: activeMonth.toFormat('yyyy-MM-dd') } },
      { query: GET_TRANSACTION, variables: { id: transactionId } }
    ]
  })

  if (allocation.budget.name === 'Spendable') {
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

  if (allocation.budget.name === 'Spendable') return <Row allocation={allocation} />

  return (
    <SwipeableRow onPress={deleteAllocation}>
      <Row allocation={allocation} />
    </SwipeableRow>
  )
}

const Row = ({ allocation: allocation }: Props) => {
  const { styles, fontSize, colors } = useAppStyles()

  const navigation = useNavigation<NavigationProp>()
  const navigateToEdit = () => navigation.navigate('Edit Allocation', { allocationId: allocation.id })

  return (
    <TouchableHighlight onPress={navigateToEdit}>
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
    </TouchableHighlight>
  )
}

export default TransactionAllocationRow
