import React from 'react'
import { View, Text } from 'react-native'
import { useTheme } from '@react-navigation/native'
import { CurrentUser } from './graphql/CurrentUser'
import { GET_SPENDABLE } from './queries'
import { useQuery } from '@apollo/client'
import formatCurrency from 'helpers/formatCurrency'

export default function SpendableHeader() {
  const { data } = useQuery<CurrentUser>(GET_SPENDABLE)
  const { colors }: any = useTheme()

  const spendableColor = data?.currentUser.spendable.isNegative() ? 'red' : colors.text

  return (
    <View style={{ alignItems: 'center' }}>
      <Text style={{ color: spendableColor, fontWeight: 'bold', fontSize: 18 }}>
        {data && formatCurrency(data.currentUser.spendable)}
      </Text>
      <Text style={{ color: colors.secondary, fontSize: 12 }}>Spendable</Text>
    </View>
  )
}