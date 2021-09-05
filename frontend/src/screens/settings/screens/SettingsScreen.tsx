import React, { useContext, useState } from 'react'
import {
  SectionList,
  Switch,
  Text,
  View,
} from 'react-native'
import { useTheme, useNavigation } from '@react-navigation/native'
import { Ionicons } from '@expo/vector-icons'
import { TouchableHighlight } from 'react-native-gesture-handler'
import auth from '@react-native-firebase/auth'
import PushNotificationIOS from '@react-native-community/push-notification-ios'
import { useMutation, useQuery } from '@apollo/client'

import { TokenContext } from 'src/components/TokenContext'
import { GET_NOTIFICATION_SETTINGS, UPDATE_NOTIFICATION_SETTINGS } from '../queries'
import { GetNotificationSettings } from '../graphql/GetNotificationSettings'
import { UpdateNotificationSettings } from '../graphql/UpdateNotificationSettings'
import AppStyles from 'src/utils/useAppStyles'

const bankRow = () => {
  const { colors }: any = useTheme()
  const { styles, fontSize } = AppStyles()
  const navigation = useNavigation()
  const navigateToBanks = () => navigation.navigate('Banks')

  return (
    <TouchableHighlight onPress={navigateToBanks}>
      <View style={styles.row}>
        <View style={{ flex: 1 }}>
          <Text style={styles.text}>
            Banks
        </Text>
        </View>

        <View style={{ flexDirection: "row" }}>
          <Ionicons name='chevron-forward-outline' size={fontSize} color={colors.secondary} />
        </View>
      </View>
    </TouchableHighlight>
  )
}

const templatesRow = () => {
  const { colors }: any = useTheme()
  const { styles, fontSize } = AppStyles()
  const navigation = useNavigation()
  const navigateToTemplates = () => navigation.navigate('Templates')

  return (
    <TouchableHighlight onPress={navigateToTemplates}>
      <View style={styles.row}>
        <View style={{ flex: 1 }}>
          <Text style={styles.text}>
            Transaction Templates
          </Text>
        </View>

        <View style={{ flexDirection: "row" }}>
          <Ionicons name='chevron-forward-outline' size={fontSize} color={colors.secondary} />
        </View>
      </View>
    </TouchableHighlight>
  )
}

const notificationsRow = () => {
  const { styles, padding } = AppStyles()
  const [id, setId] = useState<string | null>(null)
  const [enabled, setEnabled] = useState(false)
  const { deviceToken } = useContext(TokenContext)

  PushNotificationIOS.requestPermissions()

  useQuery<GetNotificationSettings>(GET_NOTIFICATION_SETTINGS, {
    variables: { deviceToken: deviceToken },
    onCompleted: data => {
      setId(data.notificationSettings.id)
      setEnabled(data.notificationSettings.enabled)
    }
  })

  const [updateNotificationSettings] = useMutation<UpdateNotificationSettings>(UPDATE_NOTIFICATION_SETTINGS)

  const toggleSwitch = () => {
    updateNotificationSettings({ variables: { id: id, enabled: !enabled } })
    setEnabled(!enabled)
  }

  return (
    <View style={[styles.row, { padding: 0 }]}>
      <View style={{ flex: 1 }}>
        <Text style={[styles.text, { padding: padding }]}>
          Notifications
        </Text>
      </View>

      <View style={{ flexDirection: "row", paddingRight: padding }}>
        <Switch
          onValueChange={(toggleSwitch)}
          value={enabled}
        />
      </View>
    </View>
  )
}

const logoutRow = () => {
  const { styles } = AppStyles()

  return (
    <TouchableHighlight onPress={() => auth().signOut()}>
      <View style={styles.row}>
        <View style={{ flex: 1 }}>
          <Text style={styles.text}>
            Logout
          </Text>
        </View>
      </View>
    </TouchableHighlight>
  )
}

export default function SettingsScreen() {
  const { styles } = AppStyles()

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
    { data: firstSection },
    { data: secondSection },
    { data: thirdSection },
  ]

  return (
    <SectionList
      contentContainerStyle={styles.sectionListContentContainerStyle}
      sections={listData}
      renderItem={({ item }) => item.view}
      stickySectionHeadersEnabled={false}
      renderSectionHeader={({ section }) => <View style={{ paddingBottom: 36 }} />}
    />
  )
}