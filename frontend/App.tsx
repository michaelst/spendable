import { ApolloProvider } from '@apollo/client'
import { AppearanceProvider } from 'react-native-appearance'
import auth, { FirebaseAuthTypes } from '@react-native-firebase/auth'
import PushNotificationIOS from '@react-native-community/push-notification-ios'
import React, { useState, useEffect } from 'react'

import { TokenContext } from 'components/auth/TokenContext'
import Main from 'components/Main'
import AuthScreen from './components/auth/auth-screen/AuthScreen'
import createApolloClient from 'helpers/createApolloClient'

export default function App() {
  const [initializing, setInitializing] = useState(true)
  const [token, setToken] = useState<string | null>()
  const [user, setUser] = useState<FirebaseAuthTypes.User | null>()
  const [deviceToken, setDeviceToken] = useState<string | null>(null)
  const context = { deviceToken: deviceToken }

  useEffect(() => {
    const subscriber = auth().onAuthStateChanged(user => {
      setUser(user)
      if (initializing) setInitializing(false)
    })
    return subscriber // unsubscribe on unmount
  }, [])

  if (initializing) return null

  if (!user) return <AuthScreen />

  user.getIdToken().then((idToken => setToken(idToken)))

  if (!token) return null

  PushNotificationIOS.addEventListener('register', deviceToken => setDeviceToken(deviceToken))

  return (
    <AppearanceProvider>
      <TokenContext.Provider value={context}>
        <ApolloProvider client={createApolloClient(token)}>
          <Main />
        </ApolloProvider>
      </TokenContext.Provider>
    </AppearanceProvider>
  )
}
