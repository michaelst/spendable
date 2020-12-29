import React from 'react'
import { View, Text } from 'react-native'
import { useTheme } from '@react-navigation/native'
import { NativeModules } from 'react-native'

import { CurrentUser } from './graphql/CurrentUser'
import { GET_SPENDABLE } from './queries'
import { useQuery } from '@apollo/client'
import formatCurrency from 'helpers/formatCurrency'
import AppStyles from 'constants/AppStyles'

export default function SpendableHeader() {
  const { data } = useQuery<CurrentUser>(GET_SPENDABLE, {
    onCompleted: (data) => {
      NativeModules.RNUserDefaults.setSpendable(formatCurrency(data.currentUser.spendable))
    }
  })
  const { colors }: any = useTheme()
  const { styles } = AppStyles()

  const spendableColor = data?.currentUser.spendable.isNegative() ? 'red' : colors.text

  return (
    <View style={{ alignItems: 'center' }}>
      <Text style={[styles.headerTitleText, { color: spendableColor }]}>
        {data && formatCurrency(data.currentUser.spendable)}
      </Text>
      <Text style={styles.secondaryText}>Spendable</Text>
    </View>
  )
}