import React, { useContext, useState } from 'react'
import {
  SectionList,
  Switch,
  Text,
  View,
} from 'react-native'
import { useNavigation } from '@react-navigation/native'
import { TouchableHighlight } from 'react-native-gesture-handler'
import auth from '@react-native-firebase/auth'
import PushNotificationIOS from '@react-native-community/push-notification-ios'
import { ApolloError, useMutation, useQuery } from '@apollo/client'
import { TokenContext } from 'src/components/TokenContext'
import useAppStyles from 'src/utils/useAppStyles'
import { GET_NOTIFICATION_SETTINGS, REGISTER_DEVICE_TOKEN, UPDATE_NOTIFICATION_SETTINGS } from 'src/queries'
import { GetNotificationSettings } from 'src/graphql/GetNotificationSettings'
import { UpdateNotificationSettings } from 'src/graphql/UpdateNotificationSettings'
import { faChevronRight } from '@fortawesome/free-solid-svg-icons'
import { FontAwesomeIcon } from '@fortawesome/react-native-fontawesome'
import { NotificationProvider } from 'src/graphql/globalTypes'
import { RegisterDeviceToken } from 'src/graphql/RegisterDeviceToken'

const Settings = () => {
  const { styles } = useAppStyles()

  const firstSection = [
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
      renderSectionHeader={() => <View style={{ paddingBottom: 36 }} />}
      contentInsetAdjustmentBehavior="automatic"
    />
  )
}

const templatesRow = () => {
  const { styles, fontSize, colors } = useAppStyles()
  const navigation = useNavigation<NavigationProp>()
  const navigateToTemplates = () => navigation.navigate('Templates')

  return (
    <TouchableHighlight onPress={navigateToTemplates}>
      <View style={styles.inputRow}>
        <View style={{ flex: 1 }}>
          <Text style={styles.text}>
            Transaction Templates
          </Text>
        </View>

        <View style={{ flexDirection: "row" }}>
          <FontAwesomeIcon icon={faChevronRight} size={fontSize} color={colors.secondary} />
        </View>
      </View>
    </TouchableHighlight>
  )
}

const notificationsRow = () => {
  const { styles, baseUnit } = useAppStyles()
  const [id, setId] = useState<string | null>()
  const [enabled, setEnabled] = useState(false)
  const { deviceToken } = useContext(TokenContext)

  PushNotificationIOS.requestPermissions()

  const [registerDeviceToken] = useMutation<RegisterDeviceToken>(REGISTER_DEVICE_TOKEN, {
    variables: {
      input: {
        deviceToken: deviceToken,
        provider: NotificationProvider.APNS,
        enabled: false
      }
    }
  })

  useQuery<GetNotificationSettings>(GET_NOTIFICATION_SETTINGS, {
    variables: { deviceToken: deviceToken },
    onCompleted: data => {
      setId(data.notificationSettings.id)
      setEnabled(data.notificationSettings.enabled)
    },
    onError: (error) => {
      if (error.message === 'could not be found') {
        registerDeviceToken().then(({ data }) => {
          setId(data?.registerDeviceToken?.result?.id)
          setEnabled(data?.registerDeviceToken?.result?.enabled || false)
        })
      } else {
        console.log(error)
      }
    }
  })

  const [updateNotificationSettings] = useMutation<UpdateNotificationSettings>(UPDATE_NOTIFICATION_SETTINGS)

  const toggleSwitch = () => {
    updateNotificationSettings({ variables: { id: id, input: { enabled: !enabled } } })
    setEnabled(!enabled)
  }

  return (
    <View style={[styles.inputRow, { padding: baseUnit }]}>
      <View style={{ flex: 1 }}>
        <Text style={[styles.text, { padding: baseUnit }]}>
          Notifications
        </Text>
      </View>

      <View style={{ flexDirection: "row", paddingRight: baseUnit }}>
        <Switch
          onValueChange={(toggleSwitch)}
          value={enabled}
        />
      </View>
    </View>
  )
}

const logoutRow = () => {
  const { styles } = useAppStyles()

  return (
    <TouchableHighlight onPress={() => auth().signOut()}>
      <View style={styles.inputRow}>
        <View style={styles.flex}>
          <Text style={styles.dangerText}>
            Logout
          </Text>
        </View>
      </View>
    </TouchableHighlight>
  )
}

export default Settings