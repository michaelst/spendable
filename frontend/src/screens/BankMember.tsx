import React, { useLayoutEffect } from 'react'
import { useRoute, RouteProp, useNavigation } from '@react-navigation/native'
import { GET_BANK_MEMBER } from './settings/queries'
import { GetBankMember } from './settings/graphql/GetBankMember'
import { useQuery } from '@apollo/client'
import { FlatList } from 'react-native-gesture-handler'
import BankAccountRow from './settings/screens/BankAccountRow'
import { RefreshControl } from 'react-native'
import useAppStyles from 'src/utils/useAppStyles'

const BankMember = () => {
  const { styles } = useAppStyles()
  const navigation = useNavigation<NavigationProp>()
  const { params: { bankMemberId } } = useRoute<RouteProp<RootStackParamList, 'Bank'>>()

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

export default BankMember
