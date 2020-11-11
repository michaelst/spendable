import React, { useLayoutEffect } from 'react'
import { FlatList, Text, } from 'react-native'
import { useNavigation } from '@react-navigation/native'
import { TouchableWithoutFeedback } from 'react-native-gesture-handler'
import FormInput, { DateField, FormField, FormFieldType } from './FormInput'
import BudgetSelect from './BudgetSelect'
import AppStyles from 'constants/AppStyles'
import DateInput from './DateInput'

type Props = {
  saveAndGoBack: () => void,
  fields: (FormField | DateField)[]
}

export default function FormScreen({ saveAndGoBack, fields }: Props) {
  const navigation = useNavigation()
  const { styles } = AppStyles()

  const headerRight = () => {
    return (
      <TouchableWithoutFeedback onPress={saveAndGoBack}>
        <Text style={styles.headerButtonText}>Save</Text>
      </TouchableWithoutFeedback>
    )
  }

  useLayoutEffect(() => navigation.setOptions({ headerTitle: '', headerRight: headerRight }))

  return (
    <FlatList
      data={fields}
      renderItem={
        ({ item }) => {
          switch(item.type) {
            case FormFieldType.BudgetSelect:
              return <BudgetSelect info={item} />
            case FormFieldType.DatePicker:
              return <DateInput info={item} />
            default:
              return <FormInput info={item} />
          }
        }
      }
    />
  )
}