import React from 'react'
import {
  StyleSheet,
  Text,
  ActivityIndicator,
  RefreshControl
} from 'react-native'
import Constants from 'expo-constants'
import { useTheme, useNavigation } from '@react-navigation/native'
import { TouchableWithoutFeedback, FlatList } from 'react-native-gesture-handler'
import { LIST_BANK_MEMBERS } from '../queries'
import { ListBankMembers } from '../graphql/ListBankMembers'
import { useQuery } from '@apollo/client'
import BankMemberRow from './BankMemberRow'


export default function BanksScreen() {
  const navigation = useNavigation()
  const { colors }: any = useTheme()

  const styles = StyleSheet.create({
    container: {
      flex: 1,
      marginTop: Constants.statusBarHeight,
    },
    activityIndicator: {
      flex: 1,
      alignItems: 'center',
      justifyContent: 'center',
    }
  })


  const { data, loading, refetch } = useQuery<ListBankMembers>(LIST_BANK_MEMBERS)
  if (loading && !data) return <ActivityIndicator color={colors.text} style={styles.activityIndicator} />

  const headerRight = () => {
    return (
      <TouchableWithoutFeedback onPress={() => navigation.navigate('Create Bank')}>
        <Text style={{ color: colors.primary, fontSize: 20, paddingRight: 20 }}>Add</Text>
      </TouchableWithoutFeedback>
    )
  }

  navigation.setOptions({headerRight: headerRight})

  return (
    <FlatList
      contentContainerStyle={{ paddingTop: 36, paddingBottom: 36 }}
      data={data?.bankMembers ?? []}
      renderItem={({ item }) => <BankMemberRow bankMember={item} />}
      refreshControl={<RefreshControl refreshing={loading} onRefresh={refetch} />}
    />
  )
}