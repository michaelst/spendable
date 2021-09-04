import React from 'react'
import { Text, View } from 'react-native'
import { GetBankMember_bankMember_bankAccounts } from '../graphql/GetBankMember'
import formatCurrency from 'src/utils/formatCurrency'
import { Switch } from 'react-native-gesture-handler'
import { useMutation } from '@apollo/client'
import { UpdateBankAccount } from '../graphql/UpdateBankAccount'
import { UPDATE_BANK_ACCOUNT } from '../queries'
import AppStyles from 'src/utils/useAppStyles'

type Props = {
  bankAccount: GetBankMember_bankMember_bankAccounts,
}

export default function BankAccountRow({ bankAccount }: Props) {
  const { styles } = AppStyles()

  const [updateBankAccount] = useMutation<UpdateBankAccount>(UPDATE_BANK_ACCOUNT)

  return (
    <View style={styles.row}>
      <View style={{ flex: 1 }}>
        <Text style={styles.text}>
          {bankAccount.name}
        </Text>
        <Text style={[styles.secondaryText, { paddingTop: 4 }]}>
          {formatCurrency(bankAccount.balance)}
        </Text>
      </View>

      <View style={{ flexDirection: "row", marginLeft: 18 }}>
        <Switch
          value={bankAccount.sync}
          onValueChange={value => updateBankAccount({ variables: { id: bankAccount.id, sync: value } })}
        />
      </View>
    </View>
  )
}
