import React from 'react'
import {
  Text,
  TextInput,
  View,
  KeyboardType,
  InputAccessoryView,
  Button
} from 'react-native'
import AppStyles from 'src/utils/useAppStyles'
import { useTheme } from '@react-navigation/native'
import Decimal from 'decimal.js-light'
import { TouchableHighlight } from 'react-native-gesture-handler'

export type FormField = {
  keyboardType?: KeyboardType,
  multiline?: boolean
  title: string,
  setValue: any,
  value: string,
}

export default function FormInput({ title, value, setValue, keyboardType, multiline = false }: FormField) {
  const { styles, padding } = AppStyles()
  const { colors }: any = useTheme()

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
          inputAccessoryViewID={keyboardType === 'decimal-pad' ? 'negate-' + title : 'none'}
        />
      </View>
      {keyboardType === 'decimal-pad' ? (
        <InputAccessoryView nativeID={'negate-' + title} backgroundColor={colors.card} style={{ padding: padding }}>
          <TouchableHighlight
            onPress={() => {
              const decimalValue = new Decimal(value)
              setValue(decimalValue.neg().toDecimalPlaces(2).toFixed(2))
            }}
            style={{
              backgroundColor: colors.secondary,
              width: 36,
              borderRadius: 8
            }}
          >
            <Text style={{ color: colors.text, padding: padding, textAlign: 'center' }}>-</Text>
          </TouchableHighlight>
        </InputAccessoryView>
      ) : null}
    </View>
  )
}