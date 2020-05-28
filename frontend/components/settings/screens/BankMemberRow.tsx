import React from 'react'
import {
  Image,
  StyleSheet,
  Text,
  TouchableHighlight,
  View
} from 'react-native'
import { useNavigation } from '@react-navigation/native'
import { useTheme } from '@react-navigation/native'
import { Ionicons } from '@expo/vector-icons'
import { ListBankMembers_bankMembers } from '../graphql/ListBankMembers'

type Props = {
  bankMember: ListBankMembers_bankMembers,
}

export default function BankRow({ bankMember }: Props) {
  const navigation = useNavigation()
  const { colors }: any = useTheme()

  const navigateToBank = () => navigation.navigate('Bank', { bankMemberId: bankMember.id })

  return (
    <TouchableHighlight onPress={navigateToBank}>
      <View
        style={{
          flexDirection: 'row',
          padding: 18,
          alignItems: 'center',
          backgroundColor: colors.card,
          borderBottomColor: colors.border,
          borderBottomWidth: StyleSheet.hairlineWidth
        }}
      >

        {bankMember.logo && (
          <Image
            source={{ uri: `data:image/png;base64,${bankMember.logo}` }}
            style={{
              width: 36,
              height: 36,
              marginRight: 8
            }}
          />
        )}
        <View style={{ flex: 1 }}>
          <Text style={{ color: colors.text, fontSize: 18 }}>
            {bankMember.name}
          </Text>
        </View>

        <View style={{ flexDirection: "row" }}>
          <Ionicons name='ios-arrow-forward' size={18} color={colors.secondary} />
        </View>
      </View>
    </TouchableHighlight>
  )
}
