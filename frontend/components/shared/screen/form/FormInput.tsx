import React from 'react'
import {
  Text,
  TextInput,
  View,
  KeyboardType
} from 'react-native'
import AppStyles from 'constants/AppStyles'

export type FormField = {
  keyboardType?: KeyboardType,
  multiline?: boolean
  title: string,
  setValue: any,
  value: string,
}

export default function FormInput({ title, value, setValue, keyboardType, multiline = false }: FormField) {
  const { styles } = AppStyles()

  return (
    <View style={styles.row}>
      <View style={{ flex: 1 }}>
        <Text style={styles.text}>
          {title}
        </Text>
      </View>

      <View style={{ width: '70%' }}>
        <TextInput
          keyboardType={keyboardType ?? 'default'}
          selectTextOnFocus={true}
          style={styles.formInputText}
          onChangeText={text => setValue(text)}
          value={value}
          multiline={multiline}
        />
      </View>
    </View>
  )
}