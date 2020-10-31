import React, { useLayoutEffect } from 'react'
import { ActivityIndicator, RefreshControl, } from 'react-native'
import { useTheme, useNavigation } from '@react-navigation/native'
import { FlatList } from 'react-native-gesture-handler'
import { LIST_BANK_MEMBERS, CREATE_BANK_MEMBER } from '../queries'
import { ListBankMembers } from '../graphql/ListBankMembers'
import { useQuery, useMutation } from '@apollo/client'
import BankMemberRow from './BankMemberRow'
import PlaidLink from 'react-native-plaid-link-sdk'
import AppStyles from 'constants/AppStyles'
import HeaderButton from 'components/shared/components/HeaderButton'

export default function BankMembersScreen() {
  const navigation = useNavigation()
  const { colors }: any = useTheme()
  const { styles } = AppStyles()

  const { data, loading, refetch } = useQuery<ListBankMembers>(LIST_BANK_MEMBERS)

  const [createBankMember] = useMutation(CREATE_BANK_MEMBER, {
    update(cache, { data: { createBankMember } }) {
      const data = cache.readQuery<ListBankMembers | null>({ query: LIST_BANK_MEMBERS })

      cache.writeQuery({
        query: LIST_BANK_MEMBERS,
        data: { bankMembers: data?.bankMembers.concat([createBankMember]) }
      })
    }
  })

  const headerRight = () => {
    return (
      <PlaidLink
        clientName="Spendable"
        publicKey="37cc44ed343b19bae3920edf047df1"
        env="sandbox"
        component={(plaid: any) => <HeaderButton text="Add" onPress={plaid.onPress} />}
        onSuccess={({ public_token: publicToken }: { public_token: String }) => createBankMember({ variables: { publicToken: publicToken } })}
        product={["transactions"]}
        language="en"
        countryCodes={["US"]}
      />
    )
  }

  useLayoutEffect(() => navigation.setOptions({ headerRight: headerRight }))

  if (loading && !data) return <ActivityIndicator color={colors.text} style={styles.activityIndicator} />

  return (
    <FlatList
      contentContainerStyle={{ paddingTop: 36, paddingBottom: 36 }}
      data={data?.bankMembers ?? []}
      renderItem={({ item }) => <BankMemberRow bankMember={item} />}
      refreshControl={<RefreshControl refreshing={loading} onRefresh={refetch} />}
    />
  )
}