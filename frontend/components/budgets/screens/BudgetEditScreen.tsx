import React, { useState, Dispatch, SetStateAction } from 'react'
import {
  FlatList,
  StyleSheet,
  Text,
  TextInput,
  View,
  KeyboardType
} from 'react-native'
import { useTheme, RouteProp, useRoute, useNavigation } from '@react-navigation/native'
import { useQuery, useMutation } from '@apollo/client'
import { RootStackParamList } from 'components/budgets/Budgets'
import { GET_BUDGET, UPDATE_BUDGET } from 'components/budgets/queries'
import { GetBudget } from 'components/budgets/graphql/GetBudget'
import { TouchableWithoutFeedback } from 'react-native-gesture-handler'

export default function BudgetEditScreen() {
  const { colors }: any = useTheme()

  const navigation = useNavigation()
  const route = useRoute<RouteProp<RootStackParamList, 'Expense'>>()
  const { budgetId } = route.params

  const { data } = useQuery<GetBudget>(GET_BUDGET, { variables: { id: budgetId } })

  const [name, setName] = useState(data?.budget.name || '')
  const [balance, setBalance] = useState(data?.budget.balance.toDecimalPlaces(2).toFixed(2) || '')
  const [goal, setGoal] = useState(data?.budget.goal?.toDecimalPlaces(2).toFixed(2) || '')

  const [updateBudget] = useMutation(UPDATE_BUDGET, {
    variables: {
      id: budgetId,
      name: name,
      balance: balance,
      goal: goal === '' ? null : goal
    }
  })


  const navigateToBudget = () => navigation.navigate('Expense', { budgetId: budgetId })
  const updateAndGoBack = () => {
    updateBudget()
    navigateToBudget()
  }

  const headerLeft = () => {
    return (
      <TouchableWithoutFeedback onPress={navigateToBudget}>
        <Text style={{ color: colors.primary, fontSize: 20, paddingLeft: 20 }}>Cancel</Text>
      </TouchableWithoutFeedback>
    )
  }

  const headerRight = () => {
    return (
      <TouchableWithoutFeedback onPress={updateAndGoBack}>
        <Text style={{ color: colors.primary, fontSize: 20, paddingRight: 20 }}>Save</Text>
      </TouchableWithoutFeedback>
    )
  }

  navigation.setOptions({ headerLeft: headerLeft, headerTitle: '', headerRight: headerRight })

  const fields: {
    key: string,
    placeholder: string,
    value: string,
    setValue: Dispatch<SetStateAction<string>>,
    keyboardType: KeyboardType
  }[] = [
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
      data={fields}
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