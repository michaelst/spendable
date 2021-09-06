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
import useAppStyles from 'src/utils/useAppStyles'
import Decimal from 'decimal.js-light'
import formatCurrency from 'src/utils/formatCurrency'
import { AllocationInputObject } from 'src/graphql/globalTypes'
import { ListAllocationTemplates, ListAllocationTemplates_allocationTemplates } from 'src/graphql/ListAllocationTemplates'
import { LIST_TEMPLATES } from 'src/queries'
import { FontAwesomeIcon } from '@fortawesome/react-native-fontawesome'
import { faChevronRight, faCross } from '@fortawesome/free-solid-svg-icons'

type Props = {
  setValue: (allocations: AllocationInputObject[]) => void,
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
  setValue: (allocations: AllocationInputObject[]) => void
}

const TemplateSelectModal = ({ modalVisible, setModalVisible, setValue }: TemplateSelectModalProps) => {
  const { styles, baseUnit, fontSize, height, colors } = useAppStyles()
  const { data } = useQuery<ListAllocationTemplates>(LIST_TEMPLATES)

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
          <FontAwesomeIcon icon={faCross} size={32} color={colors.text} />
        </TouchableHighlight>
        <FlatList
          contentContainerStyle={styles.sectionListContentContainerStyle}
          data={data?.allocationTemplates}
          renderItem={({ item }: { item: ListAllocationTemplates_allocationTemplates }) => {
            const allocated = item.lines.reduce((acc, line) => acc.add(line.amount), new Decimal('0'))

            return (
              <TouchableHighlight onPress={() => {
                const allocations = item.lines.map(line => ({ amount: line.amount.toString(), budgetId: line.budget.id }))
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