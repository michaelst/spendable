import React from 'react'
import useAppStyles from 'src/hooks/useAppStyles'
import { Text } from 'react-native'
import { TouchableWithoutFeedback } from 'react-native-gesture-handler'

type Props = {
  title: string,
  onPress: () => void
}

const HeaderButton = ({ title, onPress }: Props) => {
  const { styles } = useAppStyles()

  return (
    <TouchableWithoutFeedback onPress={onPress}>
      <Text style={styles.headerButtonText}>{title}</Text>
    </TouchableWithoutFeedback>
  )
} 

export default HeaderButton