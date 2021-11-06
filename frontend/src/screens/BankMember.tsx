import React, { useLayoutEffect } from 'react'
import { useRoute, RouteProp, useNavigation } from '@react-navigation/native'
import { useQuery } from '@apollo/client'
import { FlatList } from 'react-native-gesture-handler'
import BankAccountRow from '../components/BankAccountRow'
import { RefreshControl } from 'react-native'
import { GET_BANK_MEMBER } from 'src/queries'
import { GetBankMember } from 'src/graphql/GetBankMember'

const BankMember = () => {
  const navigation = useNavigation<NavigationProp>()
  const { params: { bankMemberId } } = useRoute<RouteProp<RootStackParamList, 'Bank'>>()

  const { data, loading, refetch } = useQuery<GetBankMember>(GET_BANK_MEMBER, { variables: { id: bankMemberId } })

  useLayoutEffect(() => {
    if (data?.bankMember) navigation.setOptions({ headerTitle: data.bankMember.name })
  })

  return (
    <FlatList
      data={data?.bankMember.bankAccounts ?? []}
      renderItem={({ item }) => <BankAccountRow bankAccount={item} />}
      refreshControl={<RefreshControl refreshing={loading} onRefresh={refetch} />}
      contentInsetAdjustmentBehavior="automatic"
    />
  )
}

export default BankMember
