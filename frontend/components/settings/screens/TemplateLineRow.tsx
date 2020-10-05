import React from 'react'
import {
  StyleSheet,
  Text,
  TouchableHighlight,
  View
} from 'react-native'
import { useNavigation } from '@react-navigation/native'
import { useTheme } from '@react-navigation/native'
import { Ionicons } from '@expo/vector-icons'
import formatCurrency from 'helpers/formatCurrency'
import { GetAllocationTemplate, GetAllocationTemplate_allocationTemplate_lines } from '../graphql/GetAllocationTemplate'
import Swipeable from 'react-native-gesture-handler/Swipeable'
import { RectButton } from 'react-native-gesture-handler'
import { DELETE_TEMPLATE_LINE, GET_TEMPLATE } from '../queries'
import { useMutation } from '@apollo/client'

type Props = {
  line: GetAllocationTemplate_allocationTemplate_lines,
  templateId: string
}

export default function TemplateRow({ line, templateId }: Props) {
  const navigation = useNavigation()
  const { colors }: any = useTheme()

  const navigateToEdit = () => navigation.navigate('Edit Template Line', { lineId: line.id })

  const [deleteAllocationTemplateLine] = useMutation(DELETE_TEMPLATE_LINE, {
    variables: { id: line.id },
    update(cache, { data: { deleteAllocationTemplateLine } }) {
      const data = cache.readQuery<GetAllocationTemplate | null>({ query: GET_TEMPLATE, variables: { id: templateId } })
      const lines = data?.allocationTemplate.lines.filter(l => l.id !== deleteAllocationTemplateLine.id)

      cache.writeQuery({
        query: GET_TEMPLATE,
        data: { allocationTemplate: {...data?.allocationTemplate, ...{lines: lines}} }
      })
    }
  })

  return (
    <TouchableHighlight onPress={navigateToEdit}>
       <Swipeable
        renderRightActions={renderRightActions}
        onSwipeableOpen={deleteAllocationTemplateLine}
      >
        <View
          style={{
            flexDirection: 'row',
            padding: 18,
            alignItems: 'center',
            backgroundColor: colors.card,
            borderBottomColor: colors.border,
            borderBottomWidth: StyleSheet.hairlineWidth
          }}
        >
          <View style={{ flex: 1 }}>
            <Text style={{ color: colors.text, fontSize: 18 }}>
              {line.budget.name}
            </Text>
          </View>

          <View style={{ flexDirection: "row" }}>
            <Text style={{ color: colors.secondary, fontSize: 18, paddingRight: 8 }} >
              {formatCurrency(line.amount)}
            </Text>
            <Ionicons name='ios-arrow-forward' size={18} color={colors.secondary} />
          </View>
        </View>
      </Swipeable>
    </TouchableHighlight>
  )
}

const styles = StyleSheet.create({
  deleteText: {
    color: 'white',
    fontSize: 16,
    padding: 10,
    fontWeight: 'bold'
  },
  rightAction: {
    alignItems: 'center',
    flex: 1,
    flexDirection: 'row',
    backgroundColor: '#dd2c00',
    justifyContent: 'flex-end'
  },
})

const renderRightActions = () => {
  return (
    <RectButton style={[styles.rightAction, { backgroundColor: '#dd2c00' }]} >
      <Text style={styles.deleteText}> Delete </Text>
    </RectButton>
  )
}
