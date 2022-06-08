import React, { useContext, useState } from 'react'
import { ActivityIndicator, Text, View } from 'react-native'
import { RouteProp, useRoute } from '@react-navigation/native'
import { useQuery, useMutation } from '@apollo/client'
import { GET_BUDGET, MAIN_QUERY, UPDATE_BUDGET } from 'src/queries'
import { GetBudget } from 'src/graphql/GetBudget'
import FormInput from 'src/components/FormInput'
import useSaveAndGoBack from 'src/hooks/useSaveAndGoBack'
import Decimal from 'decimal.js-light'
import useAppStyles from 'src/hooks/useAppStyles'
import { Switch } from 'react-native-gesture-handler'
import SettingsContext from 'src/context/Settings'

const EditBudget = () => {
  const { activeMonth } = useContext(SettingsContext)
  const { styles, colors, baseUnit } = useAppStyles()
  const { params: { budgetId } } = useRoute<RouteProp<RootStackParamList, 'Edit Budget'>>()

  const { data } = useQuery<GetBudget>(GET_BUDGET, {
    variables: {
      id: budgetId,
      startDate: activeMonth.toFormat('yyyy-MM-dd'),
      endDate: activeMonth.endOf('month').toFormat('yyyy-MM-dd')
    }
  })

  if (!data) return <ActivityIndicator color={colors.text} style={styles.activityIndicator} />

  const [name, setName] = useState(data.budget.name)
  const [balance, setBalance] = useState(data.budget.balance.toDecimalPlaces(2).toFixed(2))
  const [trackSpendingOnly, setTrackSpendingOnly] = useState(data.budget.trackSpendingOnly)
  const adjustment = new Decimal(balance).minus(data.budget.balance).add(data.budget.adjustment)

  const [updateBudget] = useMutation(UPDATE_BUDGET, {
    variables: {
      id: budgetId,
      input: {
        name: name,
        adjustment: adjustment,
        trackSpendingOnly: trackSpendingOnly
      }
    },
    refetchQueries: [{ query: MAIN_QUERY }]
  })

  useSaveAndGoBack({ mutation: updateBudget, action: "update expense" })

  return (
    <View style={{ flex: 1 }}>
      <FormInput title='Name' value={name} setValue={setName} />
      {trackSpendingOnly || <FormInput title='Balance' value={balance} setValue={setBalance} keyboardType='decimal-pad' />}
      <View style={[styles.inputRow, { padding: baseUnit }]}>
        <View style={{ flex: 1 }}>
          <Text style={[styles.text, { padding: baseUnit }]}>
            Track Spending Only
          </Text>
        </View>

        <View style={{ flexDirection: "row", paddingRight: baseUnit }}>
          <Switch
            onValueChange={() => setTrackSpendingOnly(!trackSpendingOnly)}
            value={trackSpendingOnly}
          />
        </View>
      </View>
    </View>
  )
}

export default EditBudget