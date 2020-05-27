import React from 'react'
import { NavigationContainer, DefaultTheme, DarkTheme } from '@react-navigation/native'
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs'
import { FontAwesome5, Ionicons } from '@expo/vector-icons'
import { useColorScheme } from 'react-native-appearance'
import Budgets from './budgets/Budgets'
import TransactionsScreen from './transactions/TransactionsScreen'
import Settings from './settings/Settings'

const Tab = createBottomTabNavigator()

export default function Main() {
  const colorScheme = useColorScheme()
  const baseTheme = colorScheme === 'dark' ? DarkTheme : DefaultTheme

  const theme = {
    ...baseTheme,
    colors: {
      ...baseTheme.colors,
      primary: 'rgb(50, 120, 200)',
      secondary: 'rgb(142, 142, 147)'
    }
  }

  return (
    <NavigationContainer theme={theme}>
      <Tab.Navigator
        screenOptions={({ route }) => ({
          tabBarIcon: ({ color, size }) => {
            if (route.name === 'Budgets') {
              return <FontAwesome5 name='money-check-alt' size={size} color={color} />
            } else if (route.name === 'Transactions') {
              return <FontAwesome5 name='dollar-sign' size={size} color={color} />
            } else if (route.name === 'Settings') {
              return <Ionicons name='ios-settings' size={size} color={color} />
            }
          },
        })}
      >
        <Tab.Screen name="Budgets" component={Budgets} />
        <Tab.Screen name="Transactions" component={TransactionsScreen} />
        <Tab.Screen name="Settings" component={Settings} />
      </Tab.Navigator>
    </NavigationContainer>
  )
}
