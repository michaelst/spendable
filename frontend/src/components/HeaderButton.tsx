import React from 'react'
import AppStyles from 'src/utils/useAppStyles'
import { Text } from 'react-native'
import { TouchableWithoutFeedback } from 'react-native-gesture-handler'

type Props = {
  title: string,
  onPress: () => void
}

const HeaderButton = ({ title, onPress }: Props) => {
  const { styles } = AppStyles()

  return (
    <TouchableWithoutFeedback onPress={onPress}>
      <Text style={styles.headerButtonText}>{title}</Text>
    </TouchableWithoutFeedback>
  )
} 

export default HeaderButton