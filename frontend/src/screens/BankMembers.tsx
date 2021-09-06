import React, { useLayoutEffect } from 'react'
import { ActivityIndicator, RefreshControl, Text } from 'react-native'
import { useNavigation } from '@react-navigation/native'
import { FlatList } from 'react-native-gesture-handler'
import { useQuery, useMutation } from '@apollo/client'
import BankMemberRow from '../components/BankMemberRow'
import { PlaidLink } from 'react-native-plaid-link-sdk'
import useAppStyles from 'src/utils/useAppStyles'
import { LinkSuccess } from 'react-native-plaid-link-sdk'
import { CREATE_BANK_MEMBER, GET_PLAID_LINK_TOKEN, LIST_BANK_MEMBERS } from 'src/queries'
import { ListBankMembers } from 'src/graphql/ListBankMembers'
import { GetPlaidLinkToken } from 'src/graphql/GetPlaidLinkToken'

const BankMembers = () => {
  const navigation = useNavigation<NavigationProp>()
  const { styles, colors } = useAppStyles()

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
          onSuccess={(success: LinkSuccess) => createBankMember({ variables: { publicToken: success.publicToken } })}
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
      data={data?.bankMembers ?? []}
      renderItem={({ item }) => <BankMemberRow bankMember={item} />}
      refreshControl={<RefreshControl refreshing={loading} onRefresh={refetch} />}
      contentInsetAdjustmentBehavior="automatic"
    />
  )
}

export default BankMembers