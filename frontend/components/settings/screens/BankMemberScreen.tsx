import React, { useLayoutEffect } from 'react'
import { useRoute, RouteProp, useNavigation } from '@react-navigation/native'
import { GET_BANK_MEMBER } from '../queries'
import { GetBankMember } from '../graphql/GetBankMember'
import { useQuery } from '@apollo/client'
import { FlatList } from 'react-native-gesture-handler'
import BankAccountRow from './BankAccountRow'
import { RootStackParamList } from '../Settings'
import { RefreshControl } from 'react-native'
import AppStyles from 'constants/AppStyles'

export default function BankMemberScreen() {
  const { styles } = AppStyles()
  const navigation = useNavigation()
  const route = useRoute<RouteProp<RootStackParamList, 'Bank'>>()
  const { bankMemberId } = route.params

  const { data, loading, refetch } = useQuery<GetBankMember>(GET_BANK_MEMBER, { variables: { id: bankMemberId } })

  useLayoutEffect(() => {
    if (data?.bankMember) navigation.setOptions({ headerTitle: data.bankMember.name })
  })

  return (
    <FlatList
      contentContainerStyle={styles.flatlistContentContainerStyle}
      data={data?.bankMember.bankAccounts ?? []}
      renderItem={({ item }) => <BankAccountRow bankAccount={item} />}
      refreshControl={<RefreshControl refreshing={loading} onRefresh={refetch} />}
    />
  )
}
