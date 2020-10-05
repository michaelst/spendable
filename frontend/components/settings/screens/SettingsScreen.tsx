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
import { Ionicons } from '@expo/vector-icons'
import { TouchableHighlight } from 'react-native-gesture-handler'
import { TokenContext } from 'components/auth/TokenContext'
import * as SecureStore from 'expo-secure-store'

const bankRow = () => {
  const { colors }: any = useTheme()
  const navigation = useNavigation()
  const navigateToBanks = () => navigation.navigate('Banks')

  return (
    <TouchableHighlight onPress={navigateToBanks}>
      <View
        style={{
          flexDirection: 'row',
          padding: 18,
          alignItems: 'center',
          backgroundColor: colors.card,
          borderBottomColor: colors.border,
          borderBottomWidth: StyleSheet.hairlineWidth
        }}
      >
        <View style={{ flex: 1 }}>
          <Text style={{ color: colors.text, fontSize: 18 }}>
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
  const navigation = useNavigation()
  const navigateToTemplates = () => navigation.navigate('Templates')

  return (
    <TouchableHighlight onPress={navigateToTemplates}>
      <View
        style={{
          flexDirection: 'row',
          padding: 18,
          alignItems: 'center',
          backgroundColor: colors.card,
          borderBottomColor: colors.border,
          borderBottomWidth: StyleSheet.hairlineWidth
        }}
      >
        <View style={{ flex: 1 }}>
          <Text style={{ color: colors.text, fontSize: 18 }}>
            Transaction Templates
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

  return (
    <View
      style={{
        flexDirection: 'row',
        alignItems: 'center',
        backgroundColor: colors.card,
        borderBottomColor: colors.border,
        borderBottomWidth: StyleSheet.hairlineWidth
      }}
    >
      <View style={{ flex: 1 }}>
        <Text style={{ color: colors.text, fontSize: 18, padding: 18 }}>
          Notifications
        </Text>
      </View>

      <View style={{ flexDirection: "row", paddingRight: 18 }}>
        <Switch />
      </View>
    </View>
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
              padding: 18,
              alignItems: 'center',
              backgroundColor: colors.card,
              borderBottomColor: colors.border,
              borderBottomWidth: StyleSheet.hairlineWidth
            }}
          >
            <View style={{ flex: 1 }}>
              <Text style={{ color: colors.primary, fontSize: 18 }}>
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
      contentContainerStyle={{ paddingBottom: 36 }}
      sections={listData}
      renderItem={({ item }) => item.view}
      stickySectionHeadersEnabled={false}
      renderSectionHeader={({ section }) => <View style={{ paddingBottom: 36 }} />}
    />
  )
}