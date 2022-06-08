import React from 'react'
import {
  Animated,
  StyleSheet,
  Text,
  View,
  I18nManager,
  Alert,
} from 'react-native'

import { RectButton } from 'react-native-gesture-handler'

import Swipeable from 'react-native-gesture-handler/Swipeable'

const SwipeableRow = ({ children, onPress }) => {
  const renderRightAction = (
    text: string,
    color: string,
    x: number,
    progress: Animated.AnimatedInterpolation
  ) => {
    const trans = progress.interpolate({
      inputRange: [0, 1],
      outputRange: [x, 0],
    })

    return (
      <Animated.View style={{ flex: 1, transform: [{ translateX: trans }] }}>
        <RectButton
          style={[styles.rightAction, { backgroundColor: color }]}
          onPress={onPress}>
          <Text style={styles.actionText}>{text}</Text>
        </RectButton>
      </Animated.View>
    )
  }

  const renderRightActions = (
    progress: Animated.AnimatedInterpolation,
    _dragAnimatedValue: Animated.AnimatedInterpolation
  ) => (
    <View
      style={{
        width: 120,
        flexDirection: I18nManager.isRTL ? 'row-reverse' : 'row',
      }}>
      {renderRightAction('Delete', '#dd2c00', 120, progress)}
    </View>
  )

  return (
    <Swipeable
      friction={2}
      enableTrackpadTwoFingerGesture
      leftThreshold={30}
      rightThreshold={40}
      renderRightActions={renderRightActions}>
      {children}
    </Swipeable>
  )
}

export default SwipeableRow

const styles = StyleSheet.create({
  leftAction: {
    flex: 1,
    backgroundColor: '#497AFC',
    justifyContent: 'center',
  },
  actionText: {
    color: 'white',
    fontSize: 16,
    backgroundColor: 'transparent',
    padding: 10,
  },
  rightAction: {
    alignItems: 'center',
    flex: 1,
    justifyContent: 'center',
  },
})