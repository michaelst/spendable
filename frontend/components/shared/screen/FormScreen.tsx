import React, { Dispatch, SetStateAction, useLayoutEffect } from 'react'
import {
  FlatList,
  StyleSheet,
  Text,
  TextInput,
  View,
  KeyboardType
} from 'react-native'
import { useTheme, useNavigation } from '@react-navigation/native'
import { TouchableWithoutFeedback } from 'react-native-gesture-handler'

type Props = {
  saveAndGoBack: () => void,
  fields: FormFields
}

export type FormFields = {
  key: string,
  placeholder: string,
  value: string,
  setValue: Dispatch<SetStateAction<string>>,
  keyboardType: KeyboardType
}[]

export default function FormScreen({ saveAndGoBack, fields }: Props) {
  const navigation = useNavigation()
  const { colors }: any = useTheme()

  const headerRight = () => {
    return (
      <TouchableWithoutFeedback onPress={saveAndGoBack}>
        <Text style={{ color: colors.primary, fontSize: 18, paddingRight: 18 }}>Save</Text>
      </TouchableWithoutFeedback>
    )
  }

  useLayoutEffect(() => navigation.setOptions({ headerTitle: '', headerRight: headerRight }))

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