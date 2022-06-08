import React from 'react'
import { Text, View } from 'react-native'
import useAppStyles from 'src/hooks/useAppStyles'

export type RowProps = {
  key: string
  leftSide: string
  rightSide: string
}

const Row = ({ leftSide, rightSide }: RowProps) => {
  const { styles } = useAppStyles()

  return (
    <View style={styles.row}>
      <View style={styles.flex}>
        <Text style={styles.text}>
          {leftSide}
        </Text>
      </View>

      <View style={{ flexDirection: "row" }}>
        <Text style={styles.rightText} >
          {rightSide}
        </Text>
      </View>
    </View>
  )
}

export default Row
