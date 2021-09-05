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
import { createStackNavigator } from '@react-navigation/stack'
import BankMemberScreen from 'src/screens/settings/screens/BankMemberScreen'
import BankMembersScreen from 'src/screens/settings/screens/BankMembersScreen'
import BudgetCreateScreen from 'src/screens/CreateBudget'
import BudgetEditScreen from 'src/screens/EditBudget'
import Budget from 'src/screens/Budget'
import CreateAllocation from 'src/screens/CreateAllocation'
import CreateTemplate from 'src/screens/settings/screens/CreateTemplate'
import CreateTransaction from 'src/screens/CreateTransaction'
import EditAllocation from 'src/screens/EditAllocation'
import EditTemplate from 'src/screens/settings/screens/EditTemplate'
import SettingsScreen from 'src/screens/settings/screens/SettingsScreen'
import SpendFromScreen from 'src/screens/SpendFrom'
import TemplateLineCreateScreen from 'src/screens/settings/screens/TemplateLineCreateScreen'
import TemplateLineEditScreen from 'src/screens/settings/screens/TemplateLineEditScreen'
import TemplateScreen from 'src/screens/settings/screens/TemplateScreen'
import TemplatesScreen from 'src/screens/settings/screens/TemplatesScreen'
import Transaction from 'src/screens/Transaction'
import Transactions from 'src/screens/Transactions'

const Stack = createStackNavigator<RootStackParamList>()

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
    headerBackAllowFontScaling: true,
    headerBackTitleStyle: {
      fontSize: fontSize
    }
  }
  return (
    <Stack.Navigator>
      <Stack.Screen name="Main" component={Main} options={{ headerShown: false }} />
      <Stack.Screen name="Budget" component={Budget} options={options} />
      <Stack.Screen name="Create Expense" component={BudgetCreateScreen} options={options} />
      <Stack.Screen name="Edit Expense" component={BudgetEditScreen} options={options} />
      <Stack.Screen name="Transactions" component={Transactions} options={options} />
      <Stack.Screen name="Transaction" component={Transaction} options={options} />
      <Stack.Screen name="Create Transaction" component={CreateTransaction} options={options} />
      <Stack.Screen name="Spend From" component={SpendFromScreen} options={options} />
      <Stack.Screen name="Create Allocation" component={CreateAllocation} options={options} />
      <Stack.Screen name="Edit Allocation" component={EditAllocation} options={options} />
      <Stack.Screen name="Settings" component={SettingsScreen} options={options} />
      <Stack.Screen name="Banks" component={BankMembersScreen} options={options} />
      <Stack.Screen name="Bank" component={BankMemberScreen} options={options} />
      <Stack.Screen name="Templates" component={TemplatesScreen} options={options} />
      <Stack.Screen name="Template" component={TemplateScreen} options={options} />
      <Stack.Screen name="Create Template" component={CreateTemplate} options={options} />
      <Stack.Screen name="Edit Template" component={EditTemplate} options={options} />
      <Stack.Screen name="Create Template Line" component={TemplateLineCreateScreen} options={options} />
      <Stack.Screen name="Edit Template Line" component={TemplateLineEditScreen} options={options} />
    </Stack.Navigator>
  )
}

export default App