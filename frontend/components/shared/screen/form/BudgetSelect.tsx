import React, { useState } from 'react'
import {
  Dimensions,
  SectionList,
  StyleSheet,
  Text,
  View,
} from 'react-native'
import { useTheme } from '@react-navigation/native'
import { Ionicons } from '@expo/vector-icons'
import { TouchableHighlight } from 'react-native-gesture-handler'
import Modal from 'react-native-modal'
import { SafeAreaView } from 'react-native-safe-area-context'
import { LIST_BUDGETS } from 'components/budgets/queries'
import { ListBudgets } from 'components/budgets/graphql/ListBudgets'
import { useQuery } from '@apollo/client'
import BudgetRow from './BudgetRow'
import AppStyles from 'constants/AppStyles'
import { FormField } from './FormInput'

type Props = {
  info: FormField
}

export default function BudgetSelect({ info }: Props) {
  const { colors }: any = useTheme()
  const { height } = Dimensions.get('window')
  const { styles, fontSize } = AppStyles()

  const localStyles = StyleSheet.create({
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
      padding: 16
    },
  })

  const { data } = useQuery<ListBudgets>(LIST_BUDGETS)

  const budgets = data?.budgets.filter(budget => !budget.goal).sort((a, b) => b.balance.comparedTo(a.balance)) ?? []
  const goals = data?.budgets.filter(budget => budget.goal).sort((a, b) => b.balance.comparedTo(a.balance)) ?? []

  const listData = [
    { title: "Expenses", data: budgets },
    { title: "Goals", data: goals }
  ]

  const [modalVisible, setModalVisible] = useState(false)

  return (
    <TouchableHighlight onPress={() => setModalVisible(true)}>
      <View style={styles.row}>
        <View style={{ flex: 1 }}>
          <Text style={styles.text}>
            {info.placeholder}
          </Text>
        </View>

        <View style={{ flex: 1, flexDirection: "row" }}>
          <Text style={[styles.formInputText, { paddingRight: 8 }]}>
            {info.value}
          </Text>
          <Ionicons name='ios-arrow-forward' size={fontSize} color={colors.secondary} />
        </View>
        <Modal
          isVisible={modalVisible}
          style={localStyles.modal}>
          <SafeAreaView style={localStyles.scrollableModal}>
            <TouchableHighlight onPress={() => setModalVisible(false)} style={localStyles.close}>
              <Ionicons name='ios-close' size={32} color={colors.text} />
            </TouchableHighlight>
            <SectionList
              contentContainerStyle={styles.sectionlistContentContainerStyle}
              sections={listData}
              renderItem={({ item }) => {
                return (
                  <BudgetRow 
                    budget={item} 
                    setBudgetId={(id) => {
                      info.setValue(id)
                      setModalVisible(false)
                    }}
                  />
                )
              }}
              renderSectionHeader={({ section: { title } }) => <Text style={styles.sectionHeaderText}>{title}</Text>}
              stickySectionHeadersEnabled={false}
            />
          </SafeAreaView>
        </Modal>
      </View>
    </TouchableHighlight>
  )
}

