import React from 'react'
import {
  SectionList,
  StyleSheet,
  Switch,
  Text,
  View,
  Platform
} from 'react-native'
import { useTheme, useNavigation } from '@react-navigation/native'
import { StackNavigationProp } from '@react-navigation/stack'
import { RootStackParamList } from 'components/settings/Settings'
import { Ionicons } from '@expo/vector-icons'
import { TouchableHighlight } from 'react-native-gesture-handler'
import { TokenContext } from 'components/auth/TokenContext'
import * as SecureStore from 'expo-secure-store'

const bankRow = () => {
  const { colors }: any = useTheme()
  const navigation = useNavigation<StackNavigationProp<RootStackParamList, 'Settings'>>()
  const navigateToBanks = () => navigation.navigate('Banks')

  return (
    <TouchableHighlight onPress={navigateToBanks}>
      <View
        style={{
          flexDirection: 'row',
          padding: 20,
          alignItems: 'center',
          backgroundColor: colors.card,
          borderBottomColor: colors.border,
          borderBottomWidth: StyleSheet.hairlineWidth
        }}
      >
        <View style={{ flex: 1 }}>
          <Text style={{ color: colors.text, fontSize: 20 }}>
            Banks
        </Text>
        </View>

        <View style={{ flexDirection: "row" }}>
          <Ionicons name='ios-arrow-forward' size={18} color={colors.secondary} />
        </View>
      </View>
    </TouchableHighlight>
  )
}

const templatesRow = () => {
  const { colors }: any = useTheme()
  const navigation = useNavigation<StackNavigationProp<RootStackParamList, 'Settings'>>()
  const navigateToTemplates = () => navigation.navigate('Templates')

  return (
    <TouchableHighlight onPress={navigateToTemplates}>
      <View
        style={{
          flexDirection: 'row',
          padding: 20,
          alignItems: 'center',
          backgroundColor: colors.card,
          borderBottomColor: colors.border,
          borderBottomWidth: StyleSheet.hairlineWidth
        }}
      >
        <View style={{ flex: 1 }}>
          <Text style={{ color: colors.text, fontSize: 20 }}>
            Budget Templates
        </Text>
        </View>

        <View style={{ flexDirection: "row" }}>
          <Ionicons name='ios-arrow-forward' size={18} color={colors.secondary} />
        </View>
      </View>
    </TouchableHighlight>
  )
}

const notificationsRow = () => {
  const { colors }: any = useTheme()
  const navigation = useNavigation<StackNavigationProp<RootStackParamList, 'Settings'>>()
  const navigateToTemplates = () => navigation.navigate('Templates')

  return (
    <TouchableHighlight onPress={navigateToTemplates}>
      <View
        style={{
          flexDirection: 'row',
          padding: 20,
          alignItems: 'center',
          backgroundColor: colors.card,
          borderBottomColor: colors.border,
          borderBottomWidth: StyleSheet.hairlineWidth
        }}
      >
        <View style={{ flex: 1 }}>
          <Text style={{ color: colors.text, fontSize: 20 }}>
            Notifications
        </Text>
        </View>

        <View style={{ flexDirection: "row" }}>
          <Switch />
        </View>
      </View>
    </TouchableHighlight>
  )
}

const logoutRow = () => {
  const { colors }: any = useTheme()

  return (
    <TokenContext.Consumer>
      {({ setToken }) => (
        <TouchableHighlight
          onPress={() => {
            Platform.OS === 'web' ? localStorage.removeItem('token') : SecureStore.deleteItemAsync('token')
            setToken(null)
          }}
        >
          <View
            style={{
              flexDirection: 'row',
              padding: 20,
              alignItems: 'center',
              backgroundColor: colors.card,
              borderBottomColor: colors.border,
              borderBottomWidth: StyleSheet.hairlineWidth
            }}
          >
            <View style={{ flex: 1 }}>
              <Text style={{ color: colors.primary, fontSize: 20 }}>
                Logout
              </Text>
            </View>
          </View>
        </TouchableHighlight>
      )}
    </TokenContext.Consumer>
  )
}

export default function BudgetsScreen() {
  const firstSection = [
    { key: 'banks', view: bankRow() },
    { key: 'templates', view: templatesRow() },
  ]

  const secondSection = [
    { key: 'notifications', view: notificationsRow() },
  ]

  const thirdSection = [
    { key: 'logout', view: logoutRow() },
  ]

  const listData = [
    { title: "test", data: firstSection },
    { data: secondSection },
    { data: thirdSection },
  ]

  return (
    <SectionList
      contentContainerStyle={{ paddingBottom: 40 }}
      sections={listData}
      renderItem={({ item }) => item.view}
      stickySectionHeadersEnabled={false}
      renderSectionHeader={({ section }) => <View style={{paddingBottom: 25}} />}
    />
  )
}