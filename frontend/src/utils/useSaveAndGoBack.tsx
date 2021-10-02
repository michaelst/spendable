import React, { useLayoutEffect, useState } from 'react'
import { ActivityIndicator, Alert, View } from 'react-native'
import { useNavigation } from '@react-navigation/core'
import HeaderButton from 'src/components/HeaderButton'
import useAppStyles from './useAppStyles'
import { FetchResult } from '@apollo/client'

export type Props = {
  mutation: () => Promise<FetchResult<any, Record<string, any>, Record<string, any>>>
  action: String
}

const useSaveAndGoBack = (props: Props) => {
  const navigation = useNavigation<NavigationProp>()
  const { styles, colors } = useAppStyles()
  const [loading, setLoading] = useState(false)

  const saveAndGoBack = () => {
    setLoading(true)
    props.mutation().then(() => {
      setLoading(false)
      navigation.goBack()
    }).catch(error => {
      console.log(error)
      Alert.alert(`Failed to ${props.action}, please try again.`)
      setLoading(false)
    })
  }

  useLayoutEffect(() => navigation.setOptions({
    headerTitle: '',
    headerRight: () => (
      <View>
        {loading ?
          <ActivityIndicator color={colors.text} style={styles.activityIndicator} /> :
          <HeaderButton onPress={saveAndGoBack} title="Save" />}
      </View>
    )
  }))
}

export default useSaveAndGoBack