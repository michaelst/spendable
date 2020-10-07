import React, { useState, useEffect } from 'react'
import { Platform } from 'react-native'
import { ApolloProvider } from '@apollo/client'
import { TokenContext } from 'components/auth/TokenContext'
import Main from 'components/Main'
import AuthScreen from './components/auth/auth-screen/AuthScreen'
import createApolloClient from 'helpers/createApolloClient'
import * as SecureStore from 'expo-secure-store'
import { AppearanceProvider } from 'react-native-appearance'
import PushNotificationIOS from '@react-native-community/push-notification-ios'

export default function App() {
  const [token, setToken] = useState<string | null>(null)
  const [deviceToken, setDeviceToken] = useState<string | null>(null)
  const context = { token: token, setToken: setToken, deviceToken: deviceToken }

  useEffect(() => {
    if (Platform.OS === 'web') {
      setToken(localStorage.getItem('token'))
    } else {
      SecureStore.getItemAsync('token').then(tokenInStore => setToken(tokenInStore))
    }
  })

  useEffect(() => {
    if (token) {
      if (Platform.OS === 'web') {
        localStorage.setItem('token', token)
      } else {
        SecureStore.setItemAsync('token', token)
      }
    }
  }, [token])

  PushNotificationIOS.addEventListener('register', deviceToken => setDeviceToken(deviceToken))

  return (
    <AppearanceProvider>
      <TokenContext.Provider value={context}>
        <ApolloProvider client={createApolloClient(token)}>
          {token ? <Main /> : <AuthScreen />}
        </ApolloProvider>
      </TokenContext.Provider>
    </AppearanceProvider>
  )
}
