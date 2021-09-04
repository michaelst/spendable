import React, { useState } from 'react'
import {
  Dimensions,
  StyleSheet,
  Text,
  View,
} from 'react-native'
import { useTheme } from '@react-navigation/native'
import { Ionicons } from '@expo/vector-icons'
import { FlatList, TouchableHighlight } from 'react-native-gesture-handler'
import Modal from 'react-native-modal'
import { SafeAreaView } from 'react-native-safe-area-context'
import { useQuery } from '@apollo/client'
import AppStyles from 'src/utils/useAppStyles'
import { LIST_TEMPLATES } from 'src/screens/settings/queries'
import { ListAllocationTemplates, ListAllocationTemplates_allocationTemplates } from 'src/screens/settings/graphql/ListAllocationTemplates'
import { AllocationInputObject } from 'graphql/globalTypes'
import Decimal from 'decimal.js-light'
import formatCurrency from 'src/utils/formatCurrency'

type Props = {
  setValue: (allocations: AllocationInputObject[]) => any,
}

export default function TemplateSelect({ setValue }: Props) {
  const { colors }: any = useTheme()
  const { height } = Dimensions.get('window')
  const { styles, padding, fontSize } = AppStyles()

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
      padding: padding * 2
    },
  })

  const [modalVisible, setModalVisible] = useState(false)
  const { data } = useQuery<ListAllocationTemplates>(LIST_TEMPLATES)

  return (
    <TouchableHighlight onPress={() => setModalVisible(true)}>
      <View>
        <Text style={styles.smallButtonText}>Apply Template</Text>

        <Modal
          isVisible={modalVisible}
          style={localStyles.modal}>
          <SafeAreaView style={localStyles.scrollableModal}>
            <TouchableHighlight onPress={() => setModalVisible(false)} style={localStyles.close}>
              <Ionicons name='ios-close' size={32} color={colors.text} />
            </TouchableHighlight>
            <FlatList
              contentContainerStyle={styles.sectionListContentContainerStyle}
              data={data?.allocationTemplates}
              renderItem={({ item }: { item: ListAllocationTemplates_allocationTemplates }) => {
                const allocated = item.lines.reduce((acc, line) => acc.add(line.amount), new Decimal('0'))

                return (
                  <TouchableHighlight onPress={() => {
                    const allocations = item.lines.map(line => ({ amount: line.amount, budgetId: line.budget.id }))
                    setValue(allocations)
                    setModalVisible(false)
                  }}>
                    <View style={styles.row}>
                      <View style={{ flex: 1 }}>
                        <Text style={styles.text}>
                          {item.name}
                        </Text>
                      </View>

                      <View style={{ flexDirection: "row" }}>
                        <Text style={styles.rightText} >
                          {formatCurrency(allocated)}
                        </Text>
                        <Ionicons name='chevron-forward-outline' size={fontSize} color={colors.secondary} />
                      </View>
                    </View>
                  </TouchableHighlight>
                )
              }}
            />
          </SafeAreaView>
        </Modal>
      </View>
    </TouchableHighlight >
  )
}

