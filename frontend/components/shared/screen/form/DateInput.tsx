import React, { Dispatch, SetStateAction, useState } from 'react'
import { Button, Text, View } from 'react-native'
import DateTimePickerModal from "react-native-modal-datetime-picker"
import AppStyles from 'constants/AppStyles'
import { TouchableWithoutFeedback } from 'react-native-gesture-handler'
import { DateTime } from 'luxon'

type Props = {
  info: DateField
}

export type DateField = {
  key: string,
  placeholder: string,
  value: Date,
  setValue: Dispatch<SetStateAction<Date>>,
  type: FormFieldType
}

export enum FormFieldType {
  DecimalInput,
  StringInput,
  BudgetSelect,
  DatePicker
}

export default function DateInput({ info }: Props) {
  const { styles } = AppStyles()

  const [modalVisible, setModalVisible] = useState(false)

  return (
    <View style={styles.row}>
      <View style={{ flex: 1 }}>
        <Text style={styles.text}>
          {info.placeholder}
        </Text>
      </View>

      <View style={{ width: '70%' }}>
        <TouchableWithoutFeedback onPress={() => setModalVisible(true)}>
          <Text style={styles.formInputText}>
            {DateTime.fromJSDate(info.value).toLocaleString(DateTime.DATE_MED)}
          </Text>
        </TouchableWithoutFeedback>
        <DateTimePickerModal
          isVisible={modalVisible}
          mode="date"
          date={info.value}
          onConfirm={date => {
            info.setValue(date)
            setModalVisible(false)
          }}
          onCancel={() => setModalVisible(false)}
        />
      </View>
    </View>
  )
}