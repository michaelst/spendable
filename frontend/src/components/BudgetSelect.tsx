import React, { useState } from 'react'
import {
  SafeAreaView,
  StyleSheet,
  Text,
  View,
} from 'react-native'
import { FlatList, TouchableHighlight } from 'react-native-gesture-handler'
import Modal from 'react-native-modal'
import { useQuery } from '@apollo/client'
import { FormField } from './FormInput'
import useAppStyles from 'src/hooks/useAppStyles'
import { MAIN_QUERY } from 'src/queries'
import { Main } from 'src/graphql/Main'
import BudgetRow, { BudgetRowItem } from 'src/components/BudgetRow'
import { FontAwesomeIcon } from '@fortawesome/react-native-fontawesome'
import { faWindowClose } from '@fortawesome/free-regular-svg-icons'
import { faChevronRight } from '@fortawesome/free-solid-svg-icons'

const BudgetSelect = ({ title, value, setValue }: FormField) => {
  const { colors, fontSize, styles } = useStyles()
  const [modalVisible, setModalVisible] = useState(false)

  const { data } = useQuery<Main>(MAIN_QUERY)

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
      subText: budget.trackSpendingOnly ? "SPENT" : "REMAINING",
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
            <Text style={styles.formInputText}>
              {value}
            </Text>
            <FontAwesomeIcon icon={faChevronRight} size={fontSize} color={colors.secondary} />
          </View>
        </View>
      </TouchableHighlight>

      <Modal
        isVisible={modalVisible}
        style={styles.modal}>
        <SafeAreaView style={styles.scrollableModal}>
          <TouchableHighlight onPress={() => setModalVisible(false)} style={styles.close}>
            <FontAwesomeIcon icon={faWindowClose} size={fontSize * 1.5} color={colors.text} />
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
      flexDirection: 'row',
      alignItems: 'center',
    }
  })

  return {
    colors: colors,
    fontSize: fontSize,
    styles: screenStyles
  }
}

export default BudgetSelect