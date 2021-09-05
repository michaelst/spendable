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
import AppStyles from 'src/utils/useAppStyles'
import HeaderButton from 'src/components/HeaderButton'
import { CREATE_BUDGET, MAIN_SCREEN_QUERY } from 'src/queries'
import { CreateBudget as CreateBudgetData } from 'src/graphql/CreateBudget'
import { MainScreen } from 'src/graphql/MainScreen'

const CreateBudget = () => {
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
    refetchQueries: [{ query: MAIN_SCREEN_QUERY }],
    update(cache, { data }) {
      const { createBudget: createBudgetData }: CreateBudgetData = data
      const cacheData = cache.readQuery<MainScreen | null>({ query: MAIN_SCREEN_QUERY })

      cache.writeQuery({
        query: MAIN_SCREEN_QUERY,
        data: { 
          ...cacheData,
          budgets: cacheData?.budgets.concat([createBudgetData]) 
        }
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

export default CreateBudget