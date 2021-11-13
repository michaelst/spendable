import React, { Dispatch, SetStateAction, useState } from 'react'
import {
  SafeAreaView,
  StyleSheet,
  Text,
  View,
} from 'react-native'
import { FlatList, TouchableHighlight } from 'react-native-gesture-handler'
import Modal from 'react-native-modal'
import { useQuery } from '@apollo/client'
import useAppStyles from 'src/hooks/useAppStyles'
import Decimal from 'decimal.js-light'
import formatCurrency from 'src/utils/formatCurrency'
import { FontAwesomeIcon } from '@fortawesome/react-native-fontawesome'
import { faWindowClose } from '@fortawesome/free-regular-svg-icons'
import { faChevronRight } from '@fortawesome/free-solid-svg-icons'
import { LIST_BUDGET_ALLOCATION_TEMPLATES } from 'src/queries'
import { ListBudgetAllocationTemplates, ListBudgetAllocationTemplates_budgetAllocationTemplates } from 'src/graphql/ListBudgetAllocationTemplates'

type BudgetAllocationInputObject = {
  amount: Decimal
  budget: {
    id: number
  }
}

type Props = {
  setValue: (budgetAllocations: BudgetAllocationInputObject[]) => void,
}

const TemplateSelect = ({ setValue }: Props) => {
  const { styles } = useAppStyles()

  const [modalVisible, setModalVisible] = useState(false)

  return (
    <>
      <TouchableHighlight onPress={() => setModalVisible(true)}>
        <View>
          <Text style={styles.smallButtonText}>Apply Template</Text>
        </View>
      </TouchableHighlight >
      <TemplateSelectModal
        modalVisible={modalVisible}
        setModalVisible={setModalVisible}
        setValue={setValue}
      />
    </>
  )
}

type TemplateSelectModalProps = {
  modalVisible: boolean
  setModalVisible: Dispatch<SetStateAction<boolean>>
  setValue: (budgetAllocations: BudgetAllocationInputObject[]) => void
}

const TemplateSelectModal = ({ modalVisible, setModalVisible, setValue }: TemplateSelectModalProps) => {
  const { styles, baseUnit, fontSize, height, colors } = useAppStyles()
  const { data } = useQuery<ListBudgetAllocationTemplates>(LIST_BUDGET_ALLOCATION_TEMPLATES)

  const componentStyles = StyleSheet.create({
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
  })

  return (
    <Modal
      isVisible={modalVisible}
      style={componentStyles.modal}>
      <SafeAreaView style={componentStyles.scrollableModal}>
        <TouchableHighlight onPress={() => setModalVisible(false)} style={componentStyles.close}>
          <FontAwesomeIcon icon={faWindowClose} size={32} color={colors.text} />
        </TouchableHighlight>
        <FlatList
          contentContainerStyle={styles.sectionListContentContainerStyle}
          data={data?.budgetAllocationTemplates}
          renderItem={({ item }: { item: ListBudgetAllocationTemplates_budgetAllocationTemplates }) => {
            const allocated = item.budgetAllocationTemplateLines.reduce((acc, line) => acc.add(line.amount), new Decimal('0'))

            return (
              <TouchableHighlight onPress={() => {
                const allocations = item.budgetAllocationTemplateLines.map(line => ({
                  amount: line.amount,
                  budget: { id: parseInt(line.budget.id) }
                }))

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
                    <FontAwesomeIcon icon={faChevronRight} size={fontSize} color={colors.secondary} />
                  </View>
                </View>
              </TouchableHighlight>
            )
          }}
        />
      </SafeAreaView>
    </Modal>
  )
}

export default TemplateSelect