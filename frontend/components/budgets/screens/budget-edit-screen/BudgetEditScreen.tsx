import React, { useState } from 'react'
import {
  FlatList,
  StyleSheet,
  Text,
  TextInput,
  View
} from 'react-native'
import { useTheme, RouteProp, useRoute, useNavigation } from '@react-navigation/native'
import { useQuery } from '@apollo/client'
import { RootStackParamList } from 'components/budgets/Budgets'
import { StackNavigationProp } from '@react-navigation/stack'
import { GET_BUDGET } from 'components/budgets/queries'
import {
  GetBudget,
  GetBudget_budget_recentAllocations as Allocation,
  GetBudget_budget_allocationTemplateLines as AllocationTemplateLine
} from 'components/budgets/graphql/GetBudget'
import { TouchableWithoutFeedback } from 'react-native-gesture-handler'

export default function BudgetRow() {
  const [name, setName] = useState('')
  const [balance, setBalance] = useState('')
  const [goal, setGoal] = useState('')

  const route = useRoute<RouteProp<RootStackParamList, 'Budget'>>()
  const navigation = useNavigation<StackNavigationProp<RootStackParamList, 'Budget'>>()
  const { budgetId } = route.params
  const { colors }: any = useTheme()
  const navigateToBudget = () => navigation.navigate('Budget', { budgetId: budgetId })
  const navigateToEdit = () => navigation.navigate('Edit Budget', { budgetId: budgetId })

  const headerLeft = () => {
    return (
      <TouchableWithoutFeedback onPress={navigateToBudget}>
        <Text style={{ color: colors.primary, fontSize: 20, paddingLeft: 20 }}>Cancel</Text>
      </TouchableWithoutFeedback>
    )
  }

  const headerRight = () => {
    return (
      <TouchableWithoutFeedback onPress={navigateToEdit}>
        <Text style={{ color: colors.primary, fontSize: 20, paddingRight: 20 }}>Save</Text>
      </TouchableWithoutFeedback>
    )
  }

  navigation.setOptions({ headerLeft: headerLeft, headerTitle: '', headerRight: headerRight })

  const data = [
    {
      key: 'name',
      placeholder: 'Name',
      value: name,
      setValue: setName,
      keyboardType: 'default'
    },
    {
      key: 'balance',
      placeholder: 'Balance',
      value: balance,
      setValue: setBalance,
      keyboardType: 'decimal-pad'
    },
    {
      key: 'goal',
      placeholder: 'Goal',
      value: goal,
      setValue: setGoal,
      keyboardType: 'decimal-pad'
    }
  ]

  return (
    <FlatList
      data={data}
      renderItem={
        ({ item }) => (
          <View
            style={{
              flexDirection: 'row',
              padding: 20,
              backgroundColor: colors.card,
              borderBottomColor: colors.border,
              borderBottomWidth: StyleSheet.hairlineWidth
            }}
          >
            <View style={{ flex: 1 }}>
              <Text
                style={{
                  color: colors.text,
                  fontSize: 20
                }}
              >
                {item.placeholder}
              </Text>
            </View>

            <View style={{ flex: 1 }}>
              <TextInput
                keyboardType={item.keyboardType}
                selectTextOnFocus={true}
                style={{
                  textAlign: 'right',
                  width: '100%',
                  fontSize: 18,
                  color: colors.secondary
                }}
                onChangeText={text => item.setValue(text)}
                value={item.value}
              />
            </View>
          </View>
        )
      }
    />
  )
}