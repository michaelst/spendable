import React from 'react'
import AppStyles from 'constants/AppStyles'
import { Text } from 'react-native'
import { TouchableWithoutFeedback } from 'react-native-gesture-handler'

type Props = {
  title: string,
  onPress: () => void
}

export default function HeaderButton({ title, onPress }: Props) {
  const { styles } = AppStyles()

  return (
    <TouchableWithoutFeedback onPress={onPress}>
      <Text style={styles.headerButtonText}>{title}</Text>
    </TouchableWithoutFeedback>
  )
} 