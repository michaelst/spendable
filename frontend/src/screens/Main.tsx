import React, { SetStateAction, useState } from 'react'
import { View, Text, StyleSheet, TouchableWithoutFeedback, SectionList } from 'react-native'
import { NativeModules } from 'react-native'
import { useQuery } from '@apollo/client'
import formatCurrency from 'src/utils/formatCurrency'
import useAppStyles from 'src/utils/useAppStyles'
import { MainScreen } from 'src/graphql/MainScreen'
import { MAIN_SCREEN_QUERY } from 'src/queries'
import { FlatList } from 'react-native-gesture-handler'
import { DateTime } from 'luxon'
import { useSafeAreaInsets } from 'react-native-safe-area-context'
import { Dispatch } from 'react'

type monthListDataItem = {
  month: string
  spent: string
}

type budgetListDataItem = {
  key: string
  title: string
  detailText: string
  subText: string
}

const Main = () => {
  const { baseUnit, styles } = useStyles()

  const { data } = useQuery<MainScreen>(MAIN_SCREEN_QUERY, {
    onCompleted: (data) => {
      NativeModules.RNUserDefaults.setSpendable(formatCurrency(data.currentUser.spendable))
    }
  })

  if (!data) return null

  const monthListData: monthListDataItem[] = [
    {
      month: 'Sep 2021',
      spent: formatCurrency(data.currentUser.spendable)
    },
    {
      month: 'Aug 2021',
      spent: formatCurrency(data.currentUser.spendable)
    },
    {
      month: 'Jul 2021',
      spent: formatCurrency(data.currentUser.spendable)
    },
    {
      month: 'Jun 2021',
      spent: formatCurrency(data.currentUser.spendable)
    },
    {
      month: 'May 2021',
      spent: formatCurrency(data.currentUser.spendable)
    },
    // add an empty space at the end
    {
      month: '',
      spent: ''
    }
  ]

  const budgetListData: budgetListDataItem[] = [
    {
      key: 'Spendable',
      title: "Spendable",
      detailText: formatCurrency(data.currentUser.spendable),
      subText: "AVAILABLE"
    },
    ...data.budgets.map(budget => ({
      key: budget.id,
      title: budget.name,
      detailText: formatCurrency(budget.balance),
      subText: "REMAINING"
    }))
  ]

  return <FlatList
    style={styles.budgetsList}
    data={budgetListData}
    renderItem={({ item }) => <BudgetItem item={item} />}
    ListHeaderComponent={<MonthsFlatList data={monthListData} />}
  />
}

type MonthsFlatListProps = {
  data: monthListDataItem[]
}

const MonthsFlatList = ({ data }: MonthsFlatListProps) => {
  const { styles } = useStyles()
  const [activeMonth, setActiveMonth] = useState(DateTime.now().toFormat('MMM yyyy'))

  return <FlatList
    style={styles.monthsList}
    data={data}
    horizontal={true}
    keyExtractor={item => item.month}
    renderItem={({ item }) => <MonthItem
      item={item}
      active={item.month === activeMonth}
      onPress={() => setActiveMonth(item.month)}
    />}
  />
}

type MonthItemProps = {
  item: monthListDataItem
  active: boolean
  onPress: () => void
}

const MonthItem = ({ item: { month, spent }, active, onPress }: MonthItemProps) => {
  const { styles } = useStyles()

  return (
    <View style={styles.monthView}>
      <TouchableWithoutFeedback onPress={onPress}>
        <View style={active ? styles.activeMonthDetails : styles.monthDetails}>
          <Text style={styles.monthDetailText}>{month}</Text>
          <Text style={styles.monthDetailSecondaryText}>{spent}</Text>
        </View>
      </TouchableWithoutFeedback>
    </View>
  )
}

type BudgetItemProps = {
  item: budgetListDataItem
}

const BudgetItem = ({ item: { title, detailText, subText } }: BudgetItemProps) => {
  const { styles } = useStyles()

  return (
    <View style={styles.budgetView}>
      <View>
        <Text style={styles.headerTitleText}>{title}</Text>
      </View>
      <View style={styles.budgetDetailView}>
        <Text style={styles.budgetDetailText}>{detailText}</Text>
        <Text style={styles.budgetDetailSubText}>{subText}</Text>
      </View>
    </View>
  )
}

const useStyles = () => {
  const { styles, colors, baseUnit } = useAppStyles()

  const screenStyles = StyleSheet.create({
    ...styles,
    monthsList: {
      backgroundColor: colors.card,
      margin: baseUnit * 2,
      paddingVertical: baseUnit * 3,
      paddingHorizontal: baseUnit * 2,
      borderRadius: baseUnit
    },
    budgetsList: {
    },
    monthView: {
      paddingHorizontal: baseUnit,
      justifyContent: 'center'
    },
    activeMonthDetails: {
      backgroundColor: colors.primary,
      padding: baseUnit * 2,
      borderRadius: baseUnit
    },
    monthDetails: {
      padding: baseUnit * 2
    },
    monthDetailText: {
      ...styles.text,
      marginBottom: baseUnit / 4
    },
    monthDetailSecondaryText: {
      ...styles.secondaryText
    },
    budgetView: {
      flexDirection: 'row',
      alignItems: 'center',
      justifyContent: 'space-between',
      borderBottomColor: colors.border,
      borderBottomWidth: StyleSheet.hairlineWidth,
      paddingVertical: baseUnit * 3,
      marginHorizontal: baseUnit * 2
    },
    budgetNameView: {

    },
    budgetDetailView: {
    },
    budgetDetailText: {
      ...styles.text,
      textAlign: 'right',
      marginBottom: baseUnit / 4
    },
    budgetDetailSubText: {
      ...styles.subText,
      textAlign: 'right'
    }
  })

  return {
    baseUnit: baseUnit,
    styles: screenStyles
  }
}

export default Main
