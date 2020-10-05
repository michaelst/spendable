import React from 'react'
import {
  StyleSheet,
  Text,
  TextInput,
  View,
  KeyboardType
} from 'react-native'
import { useTheme } from '@react-navigation/native'
import { FormField } from './FormScreen'

type Props = {
  info: FormField
}

export enum FormFieldType {
  DecimalInput,
  StringInput,
  BudgetSelect
}

export default function FormInput({ info }: Props) {
  const { colors }: any = useTheme()

  const keyboardType: KeyboardType = (() => {
    switch(info.type) {
      case FormFieldType.DecimalInput:
        return 'decimal-pad' 
      default:
        return 'default'
    }
  })()

  return (
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
          {info.placeholder}
        </Text>
      </View>

      <View style={{ flex: 1 }}>
        <TextInput
          keyboardType={keyboardType}
          selectTextOnFocus={true}
          style={{
            textAlign: 'right',
            width: '100%',
            fontSize: 18,
            color: colors.secondary
          }}
          onChangeText={text => info.setValue(text)}
          value={info.value}
        />
      </View>
    </View>
  )
}