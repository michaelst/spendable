import React from 'react'
import {
  Image,
  StyleSheet,
  Text,
  TouchableHighlight,
  View
} from 'react-native'
import { useTheme, useNavigation } from '@react-navigation/native'
import { Ionicons } from '@expo/vector-icons'
import { GetBankMember_bankMember_bankAccounts } from '../graphql/GetBankMember'
import formatCurrency from 'helpers/formatCurrency'
import { Switch } from 'react-native-gesture-handler'
import { useMutation } from '@apollo/client'
import { UpdateBankAccount } from '../graphql/UpdateBankAccount'
import { UPDATE_BANK_ACCOUNT } from '../queries'

type Props = {
  bankAccount: GetBankMember_bankMember_bankAccounts,
}

export default function BankAccountRow({ bankAccount }: Props) {
  const { colors }: any = useTheme()

  const [updateBankAccount] = useMutation<UpdateBankAccount>(UPDATE_BANK_ACCOUNT, { variables: { id: bankAccount.id } })

  return (
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

      <View style={{ flex: 1 }}>
        <Text style={{ color: colors.text, fontSize: 18, paddingBottom: 8 }}>
          {bankAccount.name}
        </Text>
        <Text style={{ color: colors.secondary, fontSize: 18 }}>
          {formatCurrency(bankAccount.balance)}
        </Text>
      </View>

      <View style={{ flexDirection: "row", marginLeft: 18 }}>
        <Switch
          value={bankAccount.sync}
          onValueChange={value => updateBankAccount({ variables: { sync: value } })}
        />
      </View>
    </View>
  )
}
