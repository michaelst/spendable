import React from 'react'
import {
  Image,
  Text,
  TouchableHighlight,
  View
} from 'react-native'
import { useNavigation } from '@react-navigation/native'
import { useTheme } from '@react-navigation/native'
import { Ionicons } from '@expo/vector-icons'
import { ListBankMembers_bankMembers } from '../graphql/ListBankMembers'
import AppStyles from 'constants/AppStyles'

type Props = {
  bankMember: ListBankMembers_bankMembers,
}

export default function BankRow({ bankMember }: Props) {
  const navigation = useNavigation()
  const { colors }: any = useTheme()
  const { styles, fontSize } = AppStyles()

  const navigateToBank = () => navigation.navigate('Bank', { bankMemberId: bankMember.id })

  return (
    <TouchableHighlight onPress={navigateToBank}>
      <View style={styles.row}>
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
          <Text style={styles.text}>
            {bankMember.name}
          </Text>
        </View>

        <View style={{ flexDirection: "row" }}>
          <Ionicons name='ios-arrow-forward' size={fontSize} color={colors.secondary} />
        </View>
      </View>
    </TouchableHighlight>
  )
}
