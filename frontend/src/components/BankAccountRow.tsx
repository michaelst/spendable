import React from 'react'
import { Text, View } from 'react-native'
import formatCurrency from 'src/utils/formatCurrency'
import { Switch } from 'react-native-gesture-handler'
import { useMutation } from '@apollo/client'
import useAppStyles from 'src/utils/useAppStyles'
import { GetBankMember_bankMember_bankAccounts } from 'src/graphql/GetBankMember'
import { UpdateBankAccount } from 'src/graphql/UpdateBankAccount'
import { UPDATE_BANK_ACCOUNT } from 'src/queries'

type Props = {
  bankAccount: GetBankMember_bankMember_bankAccounts,
}

const BankAccountRow = ({ bankAccount }: Props) => {
  const { styles } = useAppStyles()

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
          onValueChange={value => {
            updateBankAccount({ variables: { id: bankAccount.id, input: { sync: value } } })
          }}
        />
      </View>
    </View>
  )
}

export default BankAccountRow