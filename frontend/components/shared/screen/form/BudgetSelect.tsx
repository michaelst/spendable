import React, { createRef, useState } from 'react'
import {
  Dimensions,
  SectionList,
  StyleSheet,
  Text,
  View,
} from 'react-native'
import { useTheme } from '@react-navigation/native'
import { FormField } from './FormScreen'
import { Ionicons } from '@expo/vector-icons'
import { TouchableHighlight } from 'react-native-gesture-handler'
import Modal from 'react-native-modal'
import { SafeAreaView } from 'react-native-safe-area-context'
import { LIST_BUDGETS } from 'components/budgets/queries'
import { ListBudgets } from 'components/budgets/graphql/ListBudgets'
import { useQuery } from '@apollo/client'
import BudgetRow from './BudgetRow'
import AppStyles from 'constants/AppStyles'

type Props = {
  info: FormField
}

export enum FormFieldType {
  DecimalInput,
  StringInput,
  BudgetSelect
}

export default function BudgetSelect({ info }: Props) {
  const { colors }: any = useTheme()
  const { height } = Dimensions.get('window')
  const { styles } = AppStyles()

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
      <View
        style={{
          flexDirection: 'row',
          padding: 20,
          backgroundColor: colors.card,
          borderBottomColor: colors.border,
          borderBottomWidth: StyleSheet.hairlineWidth
        }}
      >
        <View style={{ flex: 1 }}>
          <Text
            style={{
              color: colors.text,
              fontSize: 20
            }}
          >
            {info.placeholder}
          </Text>
        </View>

        <View style={{ flex: 1, flexDirection: "row" }}>
          <Text
            style={{
              textAlign: 'right',
              width: '100%',
              fontSize: 18,
              paddingRight: 8,
              color: colors.secondary
            }}
          >
            {info.value}
          </Text>
          <Ionicons name='ios-arrow-forward' size={18} color={colors.secondary} />
        </View>
        <Modal
          isVisible={modalVisible}
          style={localStyles.modal}>
          <SafeAreaView style={localStyles.scrollableModal}>
            <TouchableHighlight onPress={() => setModalVisible(false)} style={localStyles.close}>
              <Ionicons name='ios-close' size={32} color={colors.text} />
            </TouchableHighlight>
            <SectionList
              contentContainerStyle={{ paddingBottom: 40 }}
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

