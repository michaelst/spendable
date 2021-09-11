import React, { useState, useEffect } from 'react'
import { useColorScheme } from 'react-native'
import { ApolloProvider } from '@apollo/client'
import { NavigationContainer, DefaultTheme, DarkTheme } from '@react-navigation/native'
import auth, { FirebaseAuthTypes } from '@react-native-firebase/auth'
import PushNotificationIOS from '@react-native-community/push-notification-ios'
import * as Sentry from "@sentry/react-native"
import { TokenContext } from 'src/components/TokenContext'
import Main from 'src/screens/Main'
import AuthScreen from './src/screens/AuthScreen'
import createApolloClient from 'src/utils/createApolloClient'
import useAppStyles, { SpendableTheme } from 'src/utils/useAppStyles'
import BankMember from 'src/screens/BankMember'
import BankMembers from 'src/screens/BankMembers'
import Budget from 'src/screens/Budget'
import CreateAllocation from 'src/screens/CreateAllocation'
import CreateBudget from 'src/screens/CreateBudget'
import CreateTemplate from 'src/screens/CreateTemplate'
import CreateTemplatLine from 'src/screens/CreateTemplateLine'
import CreateTransaction from 'src/screens/CreateTransaction'
import EditAllocation from 'src/screens/EditAllocation'
import EditBudget from 'src/screens/EditBudget'
import EditTemplate from 'src/screens/EditTemplate'
import EditTemplateLine from 'src/screens/EditTemplateLine'
import Settings from 'src/screens/Settings'
import SpendFrom from 'src/screens/SpendFrom'
import Template from 'src/screens/Template'
import Templates from 'src/screens/Templates'
import Transaction from 'src/screens/Transaction'
import Transactions from 'src/screens/Transactions'
import { createNativeStackNavigator } from '@react-navigation/native-stack'
import { BlurEffectTypes } from 'react-native-screens'

const Stack = createNativeStackNavigator<RootStackParamList>()

const App = () => {
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
      secondary: 'rgb(90, 90, 90)',
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
          <StackNavigator />
        </ApolloProvider>
      </TokenContext.Provider>
    </NavigationContainer>
  )
}

const StackNavigator = () => {
  const { fontSize } = useAppStyles()

  const options = {
    headerTitleStyle: { fontSize: fontSize },
    headerLargeTitle: true,
    headerTransparent: true,
    headerBlurEffect: 'regular' as BlurEffectTypes,
    headerBackTitleVisible: false,
    headerBackAllowFontScaling: true
  }

  const smallHeaderOptions = {
    headerTitleStyle: { fontSize: fontSize },
    headerBackTitleVisible: false,
    headerBackAllowFontScaling: true
  }

  return (
    <Stack.Navigator>
      <Stack.Screen name="Main" component={Main} options={{ headerShown: false }} />
      <Stack.Screen name="Budget" component={Budget} options={options} />
      <Stack.Screen name="Create Budget" component={CreateBudget} options={smallHeaderOptions} />
      <Stack.Screen name="Edit Budget" component={EditBudget} options={smallHeaderOptions} />
      <Stack.Screen name="Transactions" component={Transactions} options={options} />
      <Stack.Screen name="Transaction" component={Transaction} options={smallHeaderOptions} />
      <Stack.Screen name="Create Transaction" component={CreateTransaction} options={smallHeaderOptions} />
      <Stack.Screen name="Spend From" component={SpendFrom} options={options} />
      <Stack.Screen name="Create Allocation" component={CreateAllocation} options={smallHeaderOptions} />
      <Stack.Screen name="Edit Allocation" component={EditAllocation} options={smallHeaderOptions} />
      <Stack.Screen name="Settings" component={Settings} options={options} />
      <Stack.Screen name="Banks" component={BankMembers} options={options} />
      <Stack.Screen name="Bank" component={BankMember} options={options} />
      <Stack.Screen name="Templates" component={Templates} options={options} />
      <Stack.Screen name="Template" component={Template} options={options} />
      <Stack.Screen name="Create Template" component={CreateTemplate} options={smallHeaderOptions} />
      <Stack.Screen name="Edit Template" component={EditTemplate} options={smallHeaderOptions} />
      <Stack.Screen name="Create Template Line" component={CreateTemplatLine} options={smallHeaderOptions} />
      <Stack.Screen name="Edit Template Line" component={EditTemplateLine} options={smallHeaderOptions} />
    </Stack.Navigator>
  )
}

export default App