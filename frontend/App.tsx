import React, { useState, useEffect } from 'react'
import { useColorScheme } from 'react-native'
import { ApolloProvider } from '@apollo/client'
import { NavigationContainer, DefaultTheme, DarkTheme } from '@react-navigation/native'
import auth, { FirebaseAuthTypes } from '@react-native-firebase/auth'
import PushNotificationIOS from '@react-native-community/push-notification-ios'
import * as Sentry from "@sentry/react-native"
import { TokenContext } from 'src/components/TokenContext'
import { BlurEffectTypes } from 'react-native-screens'
import { createNativeStackNavigator } from '@react-navigation/native-stack'
import CodePush from 'react-native-code-push'
import AuthScreen from './src/screens/AuthScreen'
import BankMember from 'src/screens/BankMember'
import BankMembers from 'src/screens/BankMembers'
import Budget from 'src/screens/Budget'
import BudgetAllocationTemplate from 'src/screens/BudgetAllocationTemplate'
import BudgetAllocationTemplates from 'src/screens/BudgetAllocationTemplates'
import createApolloClient from 'src/utils/createApolloClient'
import CreateBudget from 'src/screens/CreateBudget'
import CreateBudgetAllocation from 'src/screens/CreateBudgetAllocation'
import CreateBudgetAllocationTemplate from 'src/screens/CreateBudgetAllocationTemplate'
import CreateBudgetAllocationTemplatLine from 'src/screens/CreateBudgetAllocationTemplateLine'
import CreateTransaction from 'src/screens/CreateTransaction'
import EditBudget from 'src/screens/EditBudget'
import EditBudgetAllocation from 'src/screens/EditBudgetAllocation'
import EditBudgetAllocationTemplate from 'src/screens/EditBudgetAllocationTemplate'
import EditBudgetAllocationTemplateLine from 'src/screens/EditBudgetAllocationTemplateLine'
import Main from 'src/screens/Main'
import Settings from 'src/screens/Settings'
import SpendFrom from 'src/screens/SpendFrom'
import Transaction from 'src/screens/Transaction'
import Transactions from 'src/screens/Transactions'
import useAppStyles, { SpendableTheme } from 'src/utils/useAppStyles'

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
      <Stack.Screen name="Create Allocation" component={CreateBudgetAllocation} options={smallHeaderOptions} />
      <Stack.Screen name="Edit Allocation" component={EditBudgetAllocation} options={smallHeaderOptions} />
      <Stack.Screen name="Settings" component={Settings} options={options} />
      <Stack.Screen name="Banks" component={BankMembers} options={options} />
      <Stack.Screen name="Bank" component={BankMember} options={options} />
      <Stack.Screen name="Templates" component={BudgetAllocationTemplates} options={options} />
      <Stack.Screen name="Template" component={BudgetAllocationTemplate} options={options} />
      <Stack.Screen name="Create Template" component={CreateBudgetAllocationTemplate} options={smallHeaderOptions} />
      <Stack.Screen name="Edit Template" component={EditBudgetAllocationTemplate} options={smallHeaderOptions} />
      <Stack.Screen name="Create Template Line" component={CreateBudgetAllocationTemplatLine} options={smallHeaderOptions} />
      <Stack.Screen name="Edit Template Line" component={EditBudgetAllocationTemplateLine} options={smallHeaderOptions} />
    </Stack.Navigator>
  )
}

export default CodePush({
  checkFrequency: CodePush.CheckFrequency.ON_APP_RESUME,
  installMode: CodePush.InstallMode.ON_NEXT_SUSPEND,
  minimumBackgroundDuration: 60,
})(App)