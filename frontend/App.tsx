import React, { useState, useEffect } from 'react'
import { useColorScheme } from 'react-native'
import { ApolloProvider } from '@apollo/client'
import { NavigationContainer, DefaultTheme, DarkTheme } from '@react-navigation/native'
import auth, { FirebaseAuthTypes } from '@react-native-firebase/auth'
import PushNotificationIOS from '@react-native-community/push-notification-ios'
import * as Sentry from "@sentry/react-native"
import { TokenContext } from 'src/screens/auth/TokenContext'
import Main from 'src/screens/Main'
import AuthScreen from './src/screens/auth/auth-screen/AuthScreen'
import createApolloClient from 'src/utils/createApolloClient'
import { SpendableTheme } from 'src/utils/useAppStyles'
import { createStackNavigator } from '@react-navigation/stack'
import BudgetScreen from 'src/screens/budgets/screens/BudgetScreen'
import BudgetCreateScreen from 'src/screens/budgets/screens/BudgetCreateScreen'
import BudgetEditScreen from 'src/screens/budgets/screens/BudgetEditScreen'

const Stack = createStackNavigator<RootStackParamList>()

export default function App() {
  const [initializing, setInitializing] = useState(true)
  const [user, setUser] = useState<FirebaseAuthTypes.User | null>()
  const [deviceToken, setDeviceToken] = useState<string | null>(null)
  const context = { deviceToken: deviceToken }

  const baseTheme = useColorScheme() === 'dark' ? DarkTheme : DefaultTheme

  const theme: SpendableTheme = {
    ...baseTheme,
    colors: {
      ...baseTheme.colors,
      primary: 'rgb(75, 145, 215)',
      secondary: 'rgb(75, 75, 75)',
      danger: 'red'
    }
  }

  Sentry.init({
    dsn: "https://367743cfa4b94f46bddca20a382cb601@o460075.ingest.sentry.io/5690083",
  })

  useEffect(() => {
    const subscriber = auth().onAuthStateChanged(user => {
      setUser(user)
      if (initializing) setInitializing(false)
    })
    return subscriber // unsubscribe on unmount
  }, [])

  if (initializing) return null

  if (!user) return <AuthScreen />

  PushNotificationIOS.addEventListener('register', deviceToken => setDeviceToken(deviceToken))

  return (
    <NavigationContainer theme={theme}>
      <TokenContext.Provider value={context}>
        <ApolloProvider client={createApolloClient()}>
              <Stack.Navigator>
                <Stack.Screen name="Main" component={Main} options={{headerShown: false}} />
                <Stack.Screen name="Expense" component={BudgetScreen} />
                <Stack.Screen name="Create Expense" component={BudgetCreateScreen} />
                <Stack.Screen name="Edit Expense" component={BudgetEditScreen} />
              </Stack.Navigator>
        </ApolloProvider>
      </TokenContext.Provider>
    </NavigationContainer>
  )
}
