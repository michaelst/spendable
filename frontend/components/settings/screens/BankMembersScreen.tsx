import React, { useLayoutEffect } from 'react'
import { ActivityIndicator, RefreshControl, Text } from 'react-native'
import { useTheme, useNavigation } from '@react-navigation/native'
import { FlatList } from 'react-native-gesture-handler'
import { GET_PLAID_LINK_TOKEN, LIST_BANK_MEMBERS, CREATE_BANK_MEMBER } from '../queries'
import { ListBankMembers } from '../graphql/ListBankMembers'
import { useQuery, useMutation } from '@apollo/client'
import BankMemberRow from './BankMemberRow'
import { PlaidLink } from 'react-native-plaid-link-sdk'
import AppStyles from 'constants/AppStyles'
import { GetPlaidLinkToken } from '../graphql/GetPlaidLinkToken'

export default function BankMembersScreen() {
  const navigation = useNavigation()
  const { colors }: any = useTheme()
  const { styles } = AppStyles()

  const { data, loading, refetch } = useQuery<ListBankMembers>(LIST_BANK_MEMBERS)
  const { data: plaidData } = useQuery<GetPlaidLinkToken>(GET_PLAID_LINK_TOKEN, { fetchPolicy: 'no-cache' })

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
    if (plaidData) {
      return (
        <PlaidLink
          tokenConfig={{ token: plaidData.currentUser.plaidLinkToken, }}
          onSuccess={({ public_token: publicToken }: { public_token: String }) => createBankMember({ variables: { publicToken: publicToken } })}
        >
          <Text style={styles.headerButtonText}>Add</Text>
        </PlaidLink>
      )
    }
  }

  useLayoutEffect(() => navigation.setOptions({ headerRight: headerRight }))

  if (loading && !data) return <ActivityIndicator color={colors.text} style={styles.activityIndicator} />

  return (
    <FlatList
      contentContainerStyle={styles.flatlistContentContainerStyle}
      data={data?.bankMembers ?? []}
      renderItem={({ item }) => <BankMemberRow bankMember={item} />}
      refreshControl={<RefreshControl refreshing={loading} onRefresh={refetch} />}
    />
  )
}