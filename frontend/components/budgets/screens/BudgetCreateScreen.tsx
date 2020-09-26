import React, { useState, Dispatch, SetStateAction, useLayoutEffect } from 'react'
import {
  FlatList,
  StyleSheet,
  Text,
  TextInput,
  View,
  KeyboardType
} from 'react-native'
import { useTheme, useNavigation } from '@react-navigation/native'
import { useMutation } from '@apollo/client'
import { CREATE_BUDGET, LIST_BUDGETS } from 'components/budgets/queries'
import { TouchableWithoutFeedback } from 'react-native-gesture-handler'
import { ListBudgets } from 'components/budgets/graphql/ListBudgets'

export default function BudgetCreateScreen() {
  const { colors }: any = useTheme()

  const navigation = useNavigation()

  const [name, setName] = useState('')
  const [balance, setBalance] = useState('0.00')
  const [goal, setGoal] = useState('')

  const [createBudget] = useMutation(CREATE_BUDGET, {
    variables: {
      name: name,
      balance: balance,
      goal: goal === '' ? null : goal
    },
    update(cache, { data: { createBudget } }) {
      const data = cache.readQuery<ListBudgets | null>({ query: LIST_BUDGETS })

      cache.writeQuery({
        query: LIST_BUDGETS,
        data: { budgets: data?.budgets.concat([createBudget]) }
      })
    }
  })

  const navigateToBudgets = () => navigation.navigate('Expenses')
  const createAndGoBack = () => {
    createBudget()
    navigateToBudgets()
  }

  const headerLeft = () => {
    return (
      <TouchableWithoutFeedback onPress={navigateToBudgets}>
        <Text style={{ color: colors.primary, fontSize: 20, paddingLeft: 20 }}>Cancel</Text>
      </TouchableWithoutFeedback>
    )
  }

  const headerRight = () => {
    return (
      <TouchableWithoutFeedback onPress={createAndGoBack}>
        <Text style={{ color: colors.primary, fontSize: 20, paddingRight: 20 }}>Save</Text>
      </TouchableWithoutFeedback>
    )
  }

  useLayoutEffect(() => navigation.setOptions({ headerLeft: headerLeft, headerTitle: '', headerRight: headerRight }))

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