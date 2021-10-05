import React from 'react'
import {
  Text,
  TextInput,
  View,
  KeyboardType,
  InputAccessoryView,
} from 'react-native'
import useAppStyles from 'src/utils/useAppStyles'
import Decimal from 'decimal.js-light'
import { TouchableHighlight } from 'react-native-gesture-handler'

export type FormField = {
  keyboardType?: KeyboardType,
  multiline?: boolean
  title: string,
  setValue: any,
  value: string,
}

const FormInput = ({ title, value, setValue, keyboardType, multiline = false }: FormField) => {
  const { styles, baseUnit, colors } = useAppStyles()

  return (
    <View style={styles.inputRow}>
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
        <InputAccessoryView nativeID={'negate-' + title} backgroundColor={colors.card} style={{ padding: baseUnit }}>
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
            <Text style={{ color: colors.text, padding: baseUnit, textAlign: 'center' }}>-</Text>
          </TouchableHighlight>
        </InputAccessoryView>
      ) : null}
    </View>
  )
}

export default FormInput