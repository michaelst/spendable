import React from 'react'
import AppStyles from 'constants/AppStyles'
import { Text } from 'react-native'
import { TouchableWithoutFeedback } from 'react-native-gesture-handler'

type Props = {
  text: string,
  onPress: () => void
}

export default function HeaderButton({ text, onPress }: Props) {
  const styles = AppStyles()

  return (
    <TouchableWithoutFeedback onPress={onPress}>
      <Text style={styles.headerButton}>{text}</Text>
    </TouchableWithoutFeedback>
  )
} 