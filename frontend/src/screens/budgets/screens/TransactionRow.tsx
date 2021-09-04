import React from 'react'
import {
  Text,
  TouchableHighlight,
  View
} from 'react-native'
import { useNavigation } from '@react-navigation/native'
import { useTheme } from '@react-navigation/native'
import { Ionicons } from '@expo/vector-icons'
import formatCurrency from 'src/utils/formatCurrency'
import AppStyles from 'src/utils/useAppStyles'
import { DateTime } from 'luxon'
import { GetBudget_budget_recentAllocations } from '../graphql/GetBudget'

type Props = {
  allocation: GetBudget_budget_recentAllocations,
}

export default function TransactionRow({ allocation }: Props) {
  const navigation = useNavigation()
  const { colors }: any = useTheme()
  const { styles, fontSize } = AppStyles()

  const navigateToTransaction = () => navigation.navigate('Transactions', {
    screen: 'Transaction',
    initial: false,
    params: { transactionId: allocation.transaction.id }
  })

  return (
    <TouchableHighlight onPress={navigateToTransaction}>
      <View style={styles.row}>
        <View style={{ flex: 1 }}>
          <Text numberOfLines={1} style={{ ...styles.text, ...{ paddingRight: 8 } }}>
            {allocation.transaction.name}
          </Text>
          <Text style={styles.secondaryText}>
            {DateTime.fromJSDate(allocation.transaction.date).toLocaleString(DateTime.DATE_MED)}
          </Text>
        </View>

        <View style={{ flexDirection: "row" }}>
          <Text
            style={{
              color: allocation.amount.isNegative() ? 'red' : colors.secondary,
              fontSize: fontSize,
              paddingRight: 8
            }}
          >
            {formatCurrency(allocation.amount)}
          </Text>
          <Ionicons name='chevron-forward-outline' size={fontSize} color={colors.secondary} />
        </View>
      </View>
    </TouchableHighlight>
  )
}