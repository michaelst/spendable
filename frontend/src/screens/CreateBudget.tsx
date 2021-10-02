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
import useAppStyles from 'src/utils/useAppStyles'
import HeaderButton from 'src/components/HeaderButton'
import { CREATE_BUDGET, MAIN_QUERY } from 'src/queries'

const CreateBudget = () => {
  const { styles } = useAppStyles()
  const navigation = useNavigation<NavigationProp>()

  const [name, setName] = useState('')
  const [balance, setBalance] = useState('0.00')

  const [createBudget] = useMutation(CREATE_BUDGET, {
    variables: {
      input: {
        name: name,
        balance: balance
      }
    },
    refetchQueries: [{ query: MAIN_QUERY }]
  })

  const createAndGoBack = () => {
    createBudget()
    navigation.goBack()
  }

  const headerLeft = () => <HeaderButton title="Cancel" onPress={() => navigation.goBack()} />
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

export default CreateBudget