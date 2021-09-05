import React, { useState, Dispatch, SetStateAction, useLayoutEffect } from 'react'
import {
  FlatList,
  Text,
  TextInput,
  View,
  KeyboardType
} from 'react-native'
import { RouteProp, useRoute, useNavigation } from '@react-navigation/native'
import { useQuery, useMutation } from '@apollo/client'
import useAppStyles from 'src/utils/useAppStyles'
import HeaderButton from 'src/components/HeaderButton'
import { GET_BUDGET, MAIN_SCREEN_QUERY, UPDATE_BUDGET } from 'src/queries'
import { GetBudget } from 'src/graphql/GetBudget'

const EditBudget = () => {
  const { styles } = useAppStyles()

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
    },
    refetchQueries: [{ query: MAIN_SCREEN_QUERY }]
  })


  const navigateToBudget = () => navigation.navigate('Expense', { budgetId: budgetId })
  const updateAndGoBack = () => {
    updateBudget()
    navigateToBudget()
  }

  const headerRight = () => <HeaderButton title="Save" onPress={updateAndGoBack} />

  useLayoutEffect(() => navigation.setOptions({ headerTitle: '', headerRight: headerRight }))

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
          <View style={styles.inputRow}>
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

export default EditBudget