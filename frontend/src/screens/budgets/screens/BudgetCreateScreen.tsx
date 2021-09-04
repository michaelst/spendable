import React, { useState, Dispatch, SetStateAction, useLayoutEffect } from 'react'
import {
  FlatList,
  Text,
  TextInput,
  View,
  KeyboardType
} from 'react-native'
import { useNavigation } from '@react-navigation/native'
import { useMutation } from '@apollo/client'
import { CREATE_BUDGET, LIST_BUDGETS } from 'src/screens/budgets/queries'
import { ListBudgets } from 'src/screens/budgets/graphql/ListBudgets'
import AppStyles from 'src/utils/useAppStyles'
import HeaderButton from 'src/screens/shared/components/HeaderButton'
import { GET_SPENDABLE } from 'src/screens/headers/spendable-header/queries'
import { CreateBudget } from '../graphql/CreateBudget'

export default function BudgetCreateScreen() {
  const { styles } = AppStyles()

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
    refetchQueries: [{ query: GET_SPENDABLE }],
    update(cache, { data }) {
      const { createBudget: createBudgetData }: CreateBudget = data
      const cacheData = cache.readQuery<ListBudgets | null>({ query: LIST_BUDGETS })

      cache.writeQuery({
        query: LIST_BUDGETS,
        data: { budgets: cacheData?.budgets.concat([createBudgetData]) }
      })
    }
  })

  const navigateToBudgets = () => navigation.navigate('Expenses')
  const createAndGoBack = () => {
    createBudget()
    navigateToBudgets()
  }

  const headerLeft = () => <HeaderButton title="Cancel" onPress={navigateToBudgets} />
  const headerRight = () => <HeaderButton title="Save" onPress={createAndGoBack} />

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
          <View style={styles.row}>
            <View style={{ flex: 1 }}>
              <Text style={styles.text}>{item.placeholder}</Text>
            </View>

            <View style={{ flex: 1 }}>
              <TextInput
                keyboardType={item.keyboardType}
                selectTextOnFocus={true}
                style={styles.formInputText}
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