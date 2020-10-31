import React, { Dispatch, SetStateAction, useLayoutEffect } from 'react'
import { FlatList, Text, } from 'react-native'
import { useNavigation } from '@react-navigation/native'
import { TouchableWithoutFeedback } from 'react-native-gesture-handler'
import FormInput from './FormInput'
import BudgetSelect from './BudgetSelect'
import AppStyles from 'constants/AppStyles'

type Props = {
  saveAndGoBack: () => void,
  fields: FormField[]
}

export enum FormFieldType {
  DecimalInput,
  StringInput,
  BudgetSelect
}

export type FormField = {
  key: string,
  placeholder: string,
  value: string,
  setValue: Dispatch<SetStateAction<string>>,
  type: FormFieldType
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
            default:
              return <FormInput info={item} />
          }
        }
      }
    />
  )
}