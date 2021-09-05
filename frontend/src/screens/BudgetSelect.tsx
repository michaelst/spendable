import React, { useState } from 'react'
import {
  StyleSheet,
  Text,
  View,
} from 'react-native'
import { Ionicons } from '@expo/vector-icons'
import { FlatList, TouchableHighlight } from 'react-native-gesture-handler'
import Modal from 'react-native-modal'
import { SafeAreaView } from 'react-native-safe-area-context'
import { useQuery } from '@apollo/client'
import BudgetRow from './shared/screen/form/BudgetRow'
import { FormField } from '../components/FormInput'
import useAppStyles from 'src/utils/useAppStyles'
import { MAIN_SCREEN_QUERY } from 'src/queries'
import { MainScreen } from 'src/graphql/MainScreen'
import { BudgetRowItem } from 'src/components/BudgetRow'

export default function BudgetSelect({ title, value, setValue }: FormField) {
  const { colors, fontSize, styles } = useStyles()
  const [modalVisible, setModalVisible] = useState(false)

  const { data } = useQuery<MainScreen>(MAIN_SCREEN_QUERY)

  if (!data) return null

  const budgetListData: BudgetRowItem[] = [
    {
      id: 'spendable',
      title: "Spendable",
      amount: data.currentUser.spendable,
      subText: "AVAILABLE",
      hideDelete: true,
      onPress: () => {
        setValue('spendable')
        setModalVisible(false)
      }
    },
    ...data.budgets.map(budget => ({
      id: budget.id,
      title: budget.name,
      amount: budget.balance,
      subText: "REMAINING",
      onPress: () => {
        setValue(budget.id)
        setModalVisible(false)
      }
    }))
  ]

  return (
    <>
      <TouchableHighlight onPress={() => setModalVisible(true)}>
        <View style={styles.inputRow}>
          <View>
            <Text style={styles.text}>
              {title}
            </Text>
          </View>

          <View style={styles.selectedView}>
            <Text style={styles.selectedText}>
              {value}
            </Text>
            <Ionicons name='chevron-forward-outline' size={fontSize} color={colors.secondary} />
          </View>
        </View>
      </TouchableHighlight>

      <Modal
        isVisible={modalVisible}
        style={styles.modal}>
        <SafeAreaView style={styles.scrollableModal}>
          <TouchableHighlight onPress={() => setModalVisible(false)} style={styles.close}>
            <Ionicons name='ios-close' size={32} color={colors.text} />
          </TouchableHighlight>
          <FlatList
            data={budgetListData}
            keyExtractor={item => item.id}
            renderItem={({ item }) => <BudgetRow item={item} />}
          />
        </SafeAreaView>
      </Modal>
    </>
  )
}

const useStyles = () => {
  const { height, styles, colors, baseUnit, fontSize } = useAppStyles()

  const screenStyles = StyleSheet.create({
    ...styles,
    modal: {
      justifyContent: 'flex-end',
      margin: 0,
    },
    scrollableModal: {
      height: height,
      backgroundColor: colors.background,
    },
    close: {
      alignItems: 'flex-end',
      padding: baseUnit * 2
    },
    selectedView: {
      flexDirection: "row",
      alignItems: 'center',
      paddingRight: baseUnit
    },
    selectedText: {
      ...styles.formInputText,
      paddingRight: baseUnit
    }
  })

  return {
    colors: colors,
    fontSize: fontSize,
    styles: screenStyles
  }
}

