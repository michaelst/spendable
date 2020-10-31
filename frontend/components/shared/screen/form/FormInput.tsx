import React from 'react'
import {
  Text,
  TextInput,
  View,
  KeyboardType
} from 'react-native'
import { FormField } from './FormScreen'
import AppStyles from 'constants/AppStyles'

type Props = {
  info: FormField
}

export enum FormFieldType {
  DecimalInput,
  StringInput,
  BudgetSelect
}

export default function FormInput({ info }: Props) {
  const { styles } = AppStyles()

  const keyboardType: KeyboardType = (() => {
    switch(info.type) {
      case FormFieldType.DecimalInput:
        return 'decimal-pad' 
      default:
        return 'default'
    }
  })()

  return (
    <View style={styles.row}>
      <View style={{ flex: 1 }}>
        <Text style={styles.text}>
          {info.placeholder}
        </Text>
      </View>

      <View style={{ flex: 1 }}>
        <TextInput
          keyboardType={keyboardType}
          selectTextOnFocus={true}
          style={styles.formInputText}
          onChangeText={text => info.setValue(text)}
          value={info.value}
        />
      </View>
    </View>
  )
}