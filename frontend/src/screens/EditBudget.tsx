import React, { useState } from 'react'
import { ActivityIndicator, View } from 'react-native'
import { RouteProp, useRoute } from '@react-navigation/native'
import { useQuery, useMutation } from '@apollo/client'
import { GET_BUDGET, MAIN_QUERY, UPDATE_BUDGET } from 'src/queries'
import { GetBudget } from 'src/graphql/GetBudget'
import FormInput from 'src/components/FormInput'
import useSaveAndGoBack from 'src/utils/useSaveAndGoBack'
import Decimal from 'decimal.js-light'
import useAppStyles from 'src/utils/useAppStyles'

const EditBudget = () => {
  const { styles, colors } = useAppStyles()
  const { params: { budgetId } } = useRoute<RouteProp<RootStackParamList, 'Edit Budget'>>()

  const { data } = useQuery<GetBudget>(GET_BUDGET, { variables: { id: budgetId } })

  if (!data) return <ActivityIndicator color={colors.text} style={styles.activityIndicator} />

  const [name, setName] = useState(data.budget.name)
  const [balance, setBalance] = useState(data.budget.balance.toDecimalPlaces(2).toFixed(2))
  const adjustment = new Decimal(balance).minus(data.budget.balance).add(data.budget.adjustment)

  const [updateBudget] = useMutation(UPDATE_BUDGET, {
    variables: {
      id: budgetId,
      input: {
        name: name,
        adjustment: adjustment
      }
    },
    refetchQueries: [{ query: MAIN_QUERY }]
  })

  useSaveAndGoBack({mutation: updateBudget, action: "update expense"})

  return (
    <View style={{ flex: 1 }}>
      <FormInput title='Name' value={name} setValue={setName} />
      <FormInput title='Balance' value={balance} setValue={setBalance} keyboardType='decimal-pad' />
    </View>
  )
}

export default EditBudget