import React from 'react'
import {
  Text,
  TouchableHighlight,
  View
} from 'react-native'
import { useNavigation } from '@react-navigation/native'
import formatCurrency from 'src/utils/formatCurrency'
import Swipeable from 'react-native-gesture-handler/Swipeable'
import { RectButton } from 'react-native-gesture-handler'
import { useMutation } from '@apollo/client'
import useAppStyles from 'src/utils/useAppStyles'
import { GetAllocationTemplate_allocationTemplate_lines } from 'src/graphql/GetAllocationTemplate'
import { DELETE_TEMPLATE_LINE } from 'src/queries'
import { FontAwesomeIcon } from '@fortawesome/react-native-fontawesome'
import { faChevronRight } from '@fortawesome/free-solid-svg-icons'

type Props = {
  line: GetAllocationTemplate_allocationTemplate_lines,
}

const TemplateLineRow = ({ line }: Props) => {
  const navigation = useNavigation<NavigationProp>()
  const { styles, fontSize, colors } = useAppStyles()

  const navigateToEdit = () => navigation.navigate('Edit Template Line', { lineId: line.id })

  const [deleteAllocationTemplateLine] = useMutation(DELETE_TEMPLATE_LINE, {
    variables: { id: line.id },
    update(cache, { data: { deleteAllocationTemplateLine } }) {
      cache.evict({ id: 'AllocationTemplateLine:' + deleteAllocationTemplateLine.id })
      cache.gc()
    }
  })

  const renderRightActions = () => {
    return (
      <RectButton style={styles.deleteButton}>
        <Text style={styles.deleteButtonText}>Delete</Text>
      </RectButton>
    )
  }

  return (
    <TouchableHighlight onPress={navigateToEdit}>
      <Swipeable
        renderRightActions={renderRightActions}
        onSwipeableOpen={deleteAllocationTemplateLine}
      >
        <View style={styles.row}>
          <View style={{ flex: 1 }}>
            <Text style={styles.text}>
              {line.budget.name}
            </Text>
          </View>

          <View style={{ flexDirection: "row" }}>
            <Text style={styles.rightText} >
              {formatCurrency(line.amount)}
            </Text>
            <FontAwesomeIcon icon={faChevronRight} size={fontSize} color={colors.secondary} />
          </View>
        </View>
      </Swipeable>
    </TouchableHighlight>
  )
}

export default TemplateLineRow